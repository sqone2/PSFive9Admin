function New-Five9InboundCampaign
{
    <#
    .SYNOPSIS
    
        Function used to create a new inbound campaign in Five9

    .NOTES
        Only FTP can be enabled using API. SFTP must be enabled using GUI

    .EXAMPLE
    
        New-Five9InboundCampaign -Name "Cold-Calls" -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 10
    
        # Creates new inbound campaign with minimum number of required parameters

    .EXAMPLE
    
        New-Five9InboundCampaign -Name "Cold-Calls" -Mode: ADVANCED -ProfileName "Cold-Calls-Profile" -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 50 `
                                 -CallWrapupEnabled $true -WrapupAgentNotReady $true -WrapupTimerMinutes 2 -WrapupTimerSeconds 30
    
        # Creates new inbound campaign in advanced mode, and enables call wrap up timer

    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of new campaign
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Description of new campaign
        [Parameter(Mandatory=$false)][string]$Description,

        <#
        Mode of new campaign. If not specified, default set to BASIC.

        Options are:
            • BASIC (Default) -  Campaign with default settings, without a campaign profile
            • ADVANCED - Campaign with a campaign profile specified in the profileName parameter
        #>
        [Parameter(Mandatory=$false)][ValidateSet('BASIC', 'ADVANCED')][string]$Mode = 'BASIC',

        # Campaign profile name. Applies only to the advanced campaign mode
        [Parameter(Mandatory=$false)][string]$ProfileName,

        # Name of IVR script to be used on new campaign
        [Parameter(Mandatory=$true)][string]$IvrScriptName,

        # Hashtable containing key value pairs mapping to IVR script parameters. Must be valid Input parameters in IVR script
        [Parameter(Mandatory=$false)][hashtable]$IvrScriptParameters = @{},

        # Maximum number of simultaneous calls. Cannot exceed the number of provisioned inbound lines for the domain.
        [Parameter(Mandatory=$true)][int]$MaxNumOfLines,

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
        [Parameter(Mandatory=$false)][Alias('WrapupDispostionName')][string]$WrapupDispositionName,

        # Not Ready reason code for agents who are automatically placed in Not Ready state after reaching the timeout
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

        $inboundCampaign = New-Object PSFive9Admin.inboundCampaign

        $inboundCampaign.type = "INBOUND"
        $inboundCampaign.typeSpecified = $true

        $inboundCampaign.name = $Name

        $inboundCampaign.mode = $Mode
        $inboundCampaign.modeSpecified = $true


        $inboundCampaign.defaultIvrSchedule = New-Object PSFive9Admin.inboundIvrScriptSchedule
        $inboundCampaign.defaultIvrSchedule.ivrSchedule = New-Object PSFive9Admin.ivrScriptSchedule
        $inboundCampaign.defaultIvrSchedule.ivrSchedule.scriptName = $IvrScriptName

        if ($PSBoundParameters.Keys -contains 'IvrScriptParameters' -and $IvrScriptParameters.Count -gt 0)
        {

            foreach ($key in $IvrScriptParameters.Keys)
            {
                $scriptParameterValue = New-Object PSFive9Admin.scriptParameterValue
                $scriptParameterValue.name = $key
                $scriptParameterValue.value = $IvrScriptParameters.$key

                $inboundCampaign.defaultIvrSchedule.ivrSchedule.scriptParameters += $scriptParameterValue
            }
        }


        if ($Mode -eq 'ADVANCED')
        {
            # if type is advanced, must also provide a campaign profile name
            if ($PSBoundParameters.Keys -notcontains 'ProfileName')
            {
                throw "Campaign Mode set as ""ADVANCED"", but no profile name was provided. Try again including the -ProfileName parameter."
                return
            }

            $inboundCampaign.profileName = $ProfileName

        }

        if ($PSBoundParameters.Keys -contains 'AutoRecord')
        {
            $inboundCampaign.autoRecord = $AutoRecord
            $inboundCampaign.autoRecordSpecified = $true
        }


        if ($PSBoundParameters.Keys -contains 'MaxNumOfLines')
        {
            $inboundCampaign.MaxNumOfLines = $MaxNumOfLines
            $inboundCampaign.maxNumOfLinesSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'Description')
        {
            $inboundCampaign.description = $Description
        }

        if ($CallWrapupEnabled -eq $true)
        {
            $inboundCampaign.callWrapup = New-Object PSFive9Admin.campaignCallWrapup
            $inboundCampaign.callWrapup.enabled = $true
            $inboundCampaign.callWrapup.enabledSpecified = $true

            if ($WrapupAgentNotReady -eq $true)
            {
                $inboundCampaign.callWrapup.agentNotReady = $true
                $inboundCampaign.callWrapup.agentNotReadySpecified = $true
            }

            if ($PSBoundParameters.Keys -contains 'WrapupDispositionName')
            {
                $inboundCampaign.callWrapup.dispostionName = $WrapupDispositionName
            }

            if ($PSBoundParameters.Keys -contains 'WrapupReasonCodeName')
            {
                $inboundCampaign.callWrapup.reasonCodeName = $WrapupReasonCodeName
            }

            $inboundCampaign.callWrapup.timeout = New-Object PSFive9Admin.timer
            $inboundCampaign.callWrapup.timeout.days = $WrapupTimerDays
            $inboundCampaign.callWrapup.timeout.hours = $WrapupTimerHours
            $inboundCampaign.callWrapup.timeout.minutes = $WrapupTimerMinutes
            $inboundCampaign.callWrapup.timeout.seconds = $WrapupTimerSeconds

        }

        if ($PSBoundParameters.Keys -contains 'TrainingMode')
        {
            $inboundCampaign.trainingMode = $TrainingMode
            $inboundCampaign.trainingModeSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'AutoRecord')
        {
            $inboundCampaign.autoRecord = $AutoRecord
            $inboundCampaign.autoRecordSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'RecordingNameAsSid')
        {
            $inboundCampaign.recordingNameAsSid = $RecordingNameAsSid
            $inboundCampaign.recordingNameAsSidSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'UseFtp')
        {
            $inboundCampaign.useFtp = $UseFtp
            $inboundCampaign.useFtpSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'FtpHost')
        {
            $inboundCampaign.ftpHost = $FtpHost
        }
    
        if ($PSBoundParameters.Keys -contains 'FtpUser')
        {
            $inboundCampaign.ftpUser = $FtpUser
        }

        if ($PSBoundParameters.Keys -contains 'FtpPassword')
        {
            $inboundCampaign.ftpPassword = $FtpPassword
        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new inbound campaign '$Name'." 
        $response = $global:DefaultFive9AdminClient.createInboundCampaign($inboundCampaign)


        return $response
    }
    catch
    {
        $_ | Write-PSFive9AdminError
		$_ | Write-Error
    }
}