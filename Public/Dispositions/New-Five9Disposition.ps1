function New-Five9Disposition
{
    <#
    .SYNOPSIS
    
        Function used to create a new Five9 disposition

    .EXAMPLE
    
        New-Five9Disposition -Name "Default-Disposition"

        # Creates a new disposition using system default values
    
    .EXAMPLE
    
        New-Five9Disposition -Name "Requested-Call-Back" -Description "Used when customer requests a callback." -AgentMustCompleteWorksheet $true -SendEmailNotification $true -Type: RedialNumber -UseRedialTimer $true -RedialAttempts 5 -RedialTimerHours 12

    
        # Creates a new disposition using specified values
    
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of new disposition. Only required parameter.
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Description of disposition
        [Parameter(Mandatory=$false)][string]$Description,

        # Whether the agent needs to complete a worksheet before selecting a disposition
        [Parameter(Mandatory=$false)][bool]$AgentMustCompleteWorksheet,

        # Whether the agent is prompted tconfirm the selection of the disposition
        [Parameter(Mandatory=$false)][bool]$AgentMustConfirm,

        # Whether the agent is prompted to confirm the selection of the disposition
        [Parameter(Mandatory=$false)][bool]$ResetAttemptsCounter,

        # Whether call details are sent as an email notification when the disposition is used by an agent
        [Parameter(Mandatory=$false)][bool]$SendEmailNotification,

        # Whether call details are sent as an instant message in the Five9 system when the disposition is used by an agent
        [Parameter(Mandatory=$false)][bool]$SendIMNotification,

        # Whether the call is included in the first call resolution statistics (customer’s needs addressed in the first call). Used primarily for inbound campaigns
        [Parameter(Mandatory=$false)][bool]$TrackAsFirstCallResolution,

        <#
        Type of disposition

        Options are:
            • FinalDisp - Any contact number of the contact is not dialed again by the current campaign
            • FinalApplyToCampaigns - Contact is not dialed again by any campaign that contains the disposition
            • AddActiveNumber - Adds the number dialed to the DNC list
            • AddAndFinalize - Adds the call results to the campaign history. This record is no longer dialing in this campaign. 
                             Does not add the contact’s other phone numbers to the DNC list.
            • AddAllNumbers - Adds all the contact’s phone numbers to the DNC list
            • DoNotDial - Number is not dialed in the campaign, but other numbers from the CRM record can be dialed
            • RedialNumber - Number is dialed again when the list to dial is completed, and the dialer starts again from the beginning.
        #>
        [Parameter(Mandatory=$false)][ValidateSet("FinalDisp", "FinalApplyToCampaigns", "AddActiveNumber", "AddAndFinalize", "AddAllNumbers", "DoNotDial", "RedialNumber")][string]$Type,

        # Number of redial attempts. 
        # Only used when -Type is set to "RedialNumber"
        [Parameter(Mandatory=$false)][bool]$UseRedialTimer,

        # Whether this disposition uses a redial timer
        # Only used when -Type is set to "RedialNumber"
        [Parameter(Mandatory=$false)][ValidateRange(1,99)][int]$RedialAttempts,

        # Number of Days
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerDays,

        # Number of Hours
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$RedialTimerHours,

        # Number of Minutes
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerMinutes,

        # Number of Seconds
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerSeconds,

        # Whether the agent can change the redial timer for this disposition
        # Only used when -Type is set to "RedialNumber"
        [Parameter(Mandatory=$false)][string]$AllowChangeTimer

    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $disposition = New-Object PSFive9Admin.disposition
        $disposition.name = $Name
        $disposition.description = $Description

        if ($PSBoundParameters.Keys -contains "AgentMustCompleteWorksheet")
        {
            $disposition.agentMustCompleteWorksheet = $AgentMustCompleteWorksheet
            $disposition.agentMustCompleteWorksheetSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "AgentMustConfirm")
        {
            $disposition.agentMustConfirm = $AgentMustConfirm
            $disposition.agentMustConfirmSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "ResetAttemptsCounter")
        {
            $disposition.resetAttemptsCounter = $ResetAttemptsCounter
            $disposition.resetAttemptsCounterSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "SendEmailNotification")
        {
            $disposition.sendEmailNotification = $SendEmailNotification
            $disposition.sendEmailNotificationSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "SendIMNotification")
        {
            $disposition.sendIMNotification = $SendIMNotification
            $disposition.sendIMNotificationSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "TrackAsFirstCallResolution")
        {
            $disposition.trackAsFirstCallResolution = $TrackAsFirstCallResolution
            $disposition.trackAsFirstCallResolutionSpecified = $true
        }
    
   
        if ($PSBoundParameters.Keys -contains "Type")
        {
            $disposition.type = $Type
            $disposition.typeSpecified = $true

             # only set timer values if type is set to RedialNumber
            if ($Type -eq "RedialNumber")
            {
                
                if ($PSBoundParameters.Keys -notcontains "UseRedialTimer")
                {
                    throw "When using disposition -Type ""RedialNumber"", please also specify -UseRedialTimer True/False."
                    return
                }

                $disposition.typeParameters = New-Object PSFive9Admin.dispositionTypeParams

                $disposition.typeParameters.useTimer = $UseRedialTimer
                $disposition.typeParameters.useTimerSpecified = $true

                if ($UseRedialTimer -eq $true)
                {
                    if ($RedialAttempts -lt 1)
                    {
                        throw "When -UseRedialTimer is set to True, you must also set -RedialAttempts to a value between 1-99."
                        return
                    }

                    if ($RedialTimerDays -lt 1 -and $RedialTimerHours -lt 1 -and $RedialTimerMinutes -lt 1)
                    {
                        throw "When -UseRedialTimer is set to True, the total -RedailTimer<unit> values must be set to at least 1 minute. For example, to redial a record after 8.5 hours, use -RedialTimerHours 8 -RedialTimerMinutes 30"
                        return
                    }

                    $disposition.typeParameters.timer = New-Object PSFive9Admin.timer
                    $disposition.typeParameters.timer.days = $RedialTimerDays
                    $disposition.typeParameters.timer.hours = $RedialTimerHours
                    $disposition.typeParameters.timer.minutes = $RedialTimerMinutes
                    $disposition.typeParameters.timer.seconds = $RedialTimerSeconds

                    $disposition.typeParameters.attempts = $RedialAttempts
                    $disposition.typeParameters.attemptsSpecified = $true

                }

                if ($PSBoundParameters.Keys -contains "AllowChangeTimer")
                {
                    $disposition.typeParameters.allowChangeTimer = $AllowChangeTimer
                    $disposition.typeParameters.allowChangeTimerSpecified = $true
                }

            }

        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new disposition '$Name'." 
        return $global:DefaultFive9AdminClient.createDisposition($disposition)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}

