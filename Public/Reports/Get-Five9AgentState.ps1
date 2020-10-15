function Get-Five9AgentState
{
    <#
    .SYNOPSIS
    
        Function used to determine agent state at a specfic date and time.
        This can be useful when trying to prove that all agents were in a not ready state which caused a call to queue in a skill.
   
    .EXAMPLE
    
        Get-Five9AgentState -Date '7/6/2020' -Time '2:52pm' -TimeZone CST
    
        # Returns all agent's state at the given date and time converted to the timezone specified
    
    .EXAMPLE
    
        Get-Five9AgentState -Date '2020/06/10' -Time '9:57:40am' -TimeZone EST -SkillName 'MultiMedia'
    
        # Returns agent's state at a given time who are skilled for "MultiMedia" at that time
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Date string to search agent availability
        [Parameter(Mandatory=$true)][datetime]$Date,

        # Time string to search agent availability
        [Parameter(Mandatory=$true)][datetime]$Time,

        <#
        Local time zone. Data pulled from Five9 will default to PST, all times will be converted to time zone specified

        Options are:
            • PST: times are not converted
            • MST: -1 hours offset
            • CST: -2 hours offset
            • EST: -3 hours offset
        #>
        [Parameter(Mandatory=$true)][ValidateSet("PST", "MST", "CST", "EST")][string]$TimeZone,

        # Optional parameter. If specified, function will return only agents skilled for this skill
        [Parameter(Mandatory=$false)][string]$SkillName
    )

    try
    {

        Test-Five9Connection -ErrorAction: Stop

Add-Type @"
public struct agentState {
    public string time;
    public string agent;
    public string state;
    public string skillAvailability;
    public string previous_state;
}
"@ -IgnoreWarnings

        # time relative to PST
        # all times returned from Five9 reporting are in PST
        $timeZoneTable = @{
            PST = 0
            MST = 1
            CST = 2
            EST = 3
        }

        [datetime]$startDate = $Date.ToShortDateString()
        [datetime]$startDateAdjusted = $startDate.AddHours(-$timeZoneTable[$TimeZone]).ToShortDateString()

        [datetime]$timeInQuestion = "$($Date.ToShortDateString()) $($Time.ToLongTimeString())"

        $timeInQuestion_PST = $timeInQuestion.AddHours(-$timeZoneTable[$TimeZone])

        $id = Start-Five9Report -FolderName 'Agent Reports' -ReportName 'Agent State Details' -StartDateTime $startDateAdjusted -EndDateTime $timeInQuestion_PST
        $records = Get-Five9ReportResult -Identifier $id -WaitSeconds 5

        if ($records.Count -lt 1)
        {
            throw "No data was returned using date and time specified."
            return
        }

        $groups = $records | group AGENT


        $final = @()
        foreach ($group in $groups)
        {
            $userObj = New-Object agentState

            $userObj.agent = $group.Name

            foreach ($record in $group.Group)
            {
                if ( $([datetime]$record.TIME).TimeOfDay -lt $timeInQuestion_PST.TimeOfDay )
                {
                    if ($record.STATE -eq 'Login')
                    {
                        $userObj.skillAvailability = $record.'SKILL AVAILABILITY'
                    }
                    elseif ($record.STATE -eq 'Ready')
                    {
                        $userObj.time = $record.TIME
                        $userObj.previous_state = $userObj.state
                        $userObj.state = $record.STATE

                        #$userObj.call_id = $null
                        #$userObj.call_type = $null
                    }
                    elseif ($record.STATE -eq 'Not Ready')
                    {
                        $userObj.time = $record.TIME
                        $userObj.previous_state = $userObj.state
                        $userObj.state = $record.STATE

                        #$userObj.call_id = $null
                        #$userObj.call_type = $null
                    }
                    elseif ($record.STATE -eq 'On Call')
                    {
                
                        $userObj.time = $record.TIME
                        $userObj.previous_state = $userObj.state
                        $userObj.state = $record.STATE

                        #$userObj.call_id = $record.'CALL ID'
                        #$userObj.call_type = $record.'CALL TYPE'

                    }
                    elseif ($record.STATE -eq 'After Call Work')
                    {
                
                        $userObj.time = $record.TIME
                        $userObj.state = $record.STATE

                        #$userObj.call_id = $record.'CALL ID'
                        #$userObj.call_type = $record.'CALL TYPE'

                    }
                    elseif  ($record.STATE -match 'Logout')
                    {
                        $userObj.time = $record.TIME
                        $userObj.previous_state = $userObj.state
                        $userObj.state = $record.STATE

                        #$userObj.call_id = $null
                        #$userObj.call_type = $null
                    }

            
                }

            }

            if ($userObj.state.Length -gt 1)
            {
                if ($userObj.state -notmatch 'On Call|After Call Work')
                {
                    #$userObj.previous_state = $null
                }

                $userObj.time = ([datetime]$userObj.time).AddHours($timeZoneTable[$TimeZone]).ToLongTimeString()

                $final += $userObj
            }

        }

        if ($PSBoundParameters.Keys -contains "SkillName")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning '$SkillName' agent states at '$timeInQuestion $TimeZone'." 
            return $final | ? {$_.state -notmatch 'Logout' -and $_.skillAvailability -match $SkillName} | sort state
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning all agent states at '$timeInQuestion $TimeZone'." 
            return $final | ? {$_.state -notmatch 'Logout'} | sort state
        }

    }
    catch
    {
        throw $_
    }
}