function Set-Five9InboundCampaign
{
    <#
    .SYNOPSIS
    
        Function used to modify an existing inbound campaign in Five9

    .EXAMPLE
    
        Set-Five9InboundCampaign -Name "Cold-Calls" -NewName "Warm-Calls" -IvrScriptName "Warm-Calls-IVR"
    
        # Changes name of existing campaign and changes IVR script

    .EXAMPLE
    
        Set-Five9InboundCampaign -Name "Warm-Calls" -AutoRecord $true -RecordingNameAsSid $true -UseFtp $true -FtpHost '192.168.1.50' -FtpUser 'admin' -FtpPassword 'P@ssword!'
    
        # Modified recording values on existing campaign
    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of existing campaign
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Optional. Will rename campaign to this new name
        [Parameter(Mandatory=$false)][string]$NewName,

        # Description of campaign
        [Parameter(Mandatory=$false)][string]$Description,

        <#
        Mode that existing campaign will be set to. If not specified, default set to BASIC.

        Options are:
            • BASIC (Default) -  Campaign with default settings, without a campaign profile
            • ADVANCED - Campaign with a campaign profile specified in the profileName parameter
        #>
        [Parameter(Mandatory=$false)][ValidateSet('BASIC', 'ADVANCED')][string]$Mode = 'BASIC',

        # Campaign profile name. Applies only to the advanced campaign mode
        [Parameter(Mandatory=$false)][string]$ProfileName,

        # Name of IVR script
        [Parameter(Mandatory=$false)][string]$IvrScriptName,

        # Hashtable containing key value pairs mapping to IVR script parameters. Must be valid Input parameters in IVR script
        # NOTE: Existing IVR Script parameters will be completely overwritten, not appended to
        [Parameter(Mandatory=$false)][hashtable]$IvrScriptParameters = @{},

        # Maximum number of simultaneous calls. Cannot exceed the number of provisioned inbound lines for the domain.
        [Parameter(Mandatory=$false)][int]$MaxNumOfLines,

        # Whether the campaign is in training mode
        [Parameter(Mandatory=$false)][bool]$TrainingMode,

        # Whether to record all calls of the campaign
        [Parameter(Mandatory=$false)][bool]$AutoRecord,

        # Whether to use FTP to transfer recordings.
        # NOTE: SFTP must be enabled in the Java Admin console
        [Parameter(Mandatory=$false)][bool]$UseFtp,

        # For FTP transfer, whether to use the session ID as the recording name
        [Parameter(Mandatory=$false)][bool]$RecordingNameAsSid,

        # Host name of the FTP server
        [Parameter(Mandatory=$false)][string]$FtpHost,

        # Username of the FTP server
        [Parameter(Mandatory=$false)][string]$FtpUser,

        # Password of the FTP server
        [Parameter(Mandatory=$false)][string]$FtpPassword,

        # Enables the "After Call Work Time Limit" setting on the campaign
        [Parameter(Mandatory=$false)][bool]$CallWrapupEnabled,

        <#
        Whether to automatically place agents who reach a call timeout in a Not Ready state

        Options are:
            • True: Set agents to Not Ready state
            • False: Do not set agents to Not Ready state
        #>
        [Parameter(Mandatory=$false)][bool]$WrapupAgentNotReady,

        # Name of disposition automatically set for the call if the timeout is reached
        # Note: Disposition must FIRST be added to campaign's list of dispositions using the GUI or "Add-Five9CampaignDisposition"
        [Parameter(Mandatory=$false)][Alias('WrapupDispostionName')][string]$WrapupDispositionName,

        # Not Ready reason code for agents who are automatically placed in Not Ready state after reaching the timeout
        # Note: Reason codes must first be enabled globally: Actions > Configure > Other > Enable Reason Codes
        [Parameter(Mandatory=$false)][string]$WrapupReasonCodeName,

        # Number of Days used on wrap up timer
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerDays,

        # Number of Hours used on wrap up timer
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$WrapupTimerHours,

        # Number of Minutes used on wrap up timer
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerMinutes,

        # Number of Seconds used on wrap up timer
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerSeconds


    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $existingCampaign = $null
        try
        {
            $existingCampaign = $global:DefaultFive9AdminClient.getInboundCampaign($Name)
        }
        catch
        {

        }
    
        if ($existingCampaign.Count -gt 1)
        {
            throw "Multiple campaigns were found using query: ""$Name"". Please try using the exact name of the campaign you're trying to modify."
            return
        }

        if ($existingCampaign -eq $null)
        {
            throw "Cannot find a campaign with name: ""$Name"". Remember that Name is case sensitive."
            return
        }

        $existingCampaign = $existingCampaign | select -First 1


        $campaignToModify = New-Object PSFive9Admin.inboundCampaign
        $campaignToModify.name = $existingCampaign.name


        if ($PSBoundParameters.Keys -contains 'Description')
        {
            $campaignToModify.description = $Description
        }

        
        if ($PSBoundParameters.Keys -contains 'IvrScriptName')
        {
            $campaignToModify.defaultIvrSchedule = New-Object PSFive9Admin.inboundIvrScriptSchedule
            $campaignToModify.defaultIvrSchedule.ivrSchedule = New-Object PSFive9Admin.ivrScriptSchedule
            
            $campaignToModify.defaultIvrSchedule.ivrSchedule.scriptName = $IvrScriptName
        }
            
        if ($existingCampaign.defaultIvrSchedule -eq $null -and $campaignToModify.defaultIvrSchedule -eq $null)
        {
            throw "The campaign being modified is not configured with an IVR Script. Please try again including the -IvrScriptName parameter."
            return
        }

        if ($PSBoundParameters.Keys -contains 'IvrScriptParameters' -and $IvrScriptParameters.Count -gt 0)
        {

            if ($campaignToModify.defaultIvrSchedule -eq $null)
            {
                $campaignToModify.defaultIvrSchedule = $existingCampaign.defaultIvrSchedule
            }

            foreach ($key in $IvrScriptParameters.Keys)
            {
                $scriptParameterValue = New-Object PSFive9Admin.scriptParameterValue
                $scriptParameterValue.name = $key
                $scriptParameterValue.value = $IvrScriptParameters.$key

                $campaignToModify.defaultIvrSchedule.ivrSchedule.scriptParameters += $scriptParameterValue
            }
        }


        if ($PSBoundParameters.Keys -contains 'Mode')
        {
            # if change is from basic to advanced, make sure that theres a profile being set as well
            if ($existingCampaign.mode -eq "BASIC" -and $Mode -eq 'ADVANCED')
            {
                # if type is advanced, must also provide a campaign profile name
                if ($PSBoundParameters.Keys -notcontains 'ProfileName')
                {
                    throw "Campaign Mode set as ""ADVANCED"", but no profile name was provided. Try again including the -ProfileName parameter."
                    return
                }

            }

            $campaignToModify.mode = $Mode
            $campaignToModify.modeSpecified = $true
        
        }


        if ($PSBoundParameters.Keys -contains 'ProfileName')
        {
            $campaignToModify.profileName = $ProfileName
        }

        if ($existingCampaign.maxNumOfLines -lt 1)
        {
            if ($PSBoundParameters.Keys -contains 'MaxNumOfLines')
            {
                $campaignToModify.MaxNumOfLines = $MaxNumOfLines
                $campaignToModify.maxNumOfLinesSpecified = $true
            }
            else
            {
                throw "The campaign being modified has zero voice lines. Please try again including the -MaxNumOfLines parameter."
                return
            }
        }
        else
        {
            if ($PSBoundParameters.Keys -contains 'MaxNumOfLines')
            {
                $campaignToModify.MaxNumOfLines = $MaxNumOfLines
                $campaignToModify.maxNumOfLinesSpecified = $true
            }
        }


        if ($PSBoundParameters.Keys -contains 'AutoRecord')
        {
            $campaignToModify.autoRecord = $AutoRecord
            $campaignToModify.autoRecordSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'RecordingNameAsSid')
        {
            $campaignToModify.recordingNameAsSid = $RecordingNameAsSid
            $campaignToModify.recordingNameAsSidSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'TrainingMode')
        {
            $campaignToModify.trainingMode = $TrainingMode
            $campaignToModify.trainingModeSpecified = $true
        }


        if ($PSBoundParameters.Keys -contains 'UseFtp')
        {
            $campaignToModify.useFtp = $UseFtp
            $campaignToModify.useFtpSpecified = $true
        }


        if ($PSBoundParameters.Keys -contains 'FtpHost')
        {
            $campaignToModify.ftpHost = $FtpHost
        }

        if ($PSBoundParameters.Keys -contains 'FtpUser')
        {
            $campaignToModify.ftpUser = $FtpUser
        }

        if ($PSBoundParameters.Keys -contains 'FtpPassword')
        {
            $campaignToModify.ftpPassword = $FtpPassword
        }


        $campaignToModify.callWrapup = $existingCampaign.callWrapup

        if ($PSBoundParameters.Keys -contains 'CallWrapupEnabled')
        {
            $campaignToModify.callWrapup.enabled = $CallWrapupEnabled
            $campaignToModify.callWrapup.enabledSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'WrapupAgentNotReady')
        {
            $campaignToModify.callWrapup.agentNotReady = $WrapupAgentNotReady
            $campaignToModify.callWrapup.agentNotReadySpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'WrapupDispositionName')
        {
            $campaignToModify.callWrapup.dispostionName = $WrapupDispositionName
        }

        if ($PSBoundParameters.Keys -contains 'WrapupReasonCodeName')
        {
            $campaignToModify.callWrapup.reasonCodeName = $WrapupReasonCodeName
        }


        if ($CallWrapupEnabled -eq $true -and $existingCampaign.callWrapup.timeout -eq $null)
        {
            $campaignToModify.callWrapup.timeout = New-Object PSFive9Admin.timer
        }

        if ($PSBoundParameters.Keys -contains 'WrapupTimerDays')
        {
            $campaignToModify.callWrapup.timeout.days = $WrapupTimerDays
        }

        if ($PSBoundParameters.Keys -contains 'WrapupTimerHours')
        {
            $campaignToModify.callWrapup.timeout.hours = $WrapupTimerHours
        }

        if ($PSBoundParameters.Keys -contains 'WrapupTimerMinutes')
        {
            $campaignToModify.callWrapup.timeout.minutes = $WrapupTimerMinutes
        }

        if ($PSBoundParameters.Keys -contains 'WrapupTimerSeconds')
        {
            $campaignToModify.callWrapup.timeout.seconds = $WrapupTimerSeconds
        }



        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying inbound campaign '$Name'." 
        $response = $global:DefaultFive9AdminClient.modifyInboundCampaign($campaignToModify)

        if ($PSBoundParameters.Keys -contains 'NewName')
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Renaming inbound campaign '$Name'." 
            $global:DefaultFive9AdminClient.renameCampaign($existingCampaign.name, $NewName)
        }



        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError
		$_ | Write-Error
    }

}