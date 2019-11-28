<#
.SYNOPSIS
    
    Function used to create a new inbound campaign in Five9
 
.PARAMETER Name

    Name of new campaign

.PARAMETER Description

     Description of new campaign


.PARAMETER Mode

    Mode of new campaign. If not specified, default set to BASIC.
    Options are:
        • BASIC (Default) -  Campaign with default settings, without a campaign profile
        • ADVANCED - Campaign with a campaign profile specified in the profileName parameter


.PARAMETER IvrScriptName

    Name of IVR script to be used on new campaign


.PARAMETER MaxNumOfLines

    Maximum number of simultaneous calls. Cannot exceed the number of provisioned inbound lines for the domain.


.PARAMETER TrainingMode

    Whether the campaign is in training mode

.PARAMETER AutoRecord

    Whether to record all calls of the campaign

.PARAMETER UseFtp

    Whether to use FTP to transfer recordings.
    NOTE: SFTP must be enabled in the Java Admin console

.PARAMETER RecordingNameAsSid

    For FTP transfer, whether to use the session ID as the recording name

.PARAMETER FtpHost

    Host name of the FTP server

.PARAMETER FtpUser

    Username of the FTP server

.PARAMETER FtpPassword

    Password of the FTP server

.PARAMETER ProfileName

    Campaign profile name. Applies only to the advanced campaign mode


.PARAMETER CallWrapupEnabled

    Enables the "After Call Work Time Limit" setting on the campaign


.PARAMETER WrapupAgentNotReady

    Whether to automatically place agents who reach a call timeout in a Not Ready state
    Options are:
        • True: Set agents to Not Ready state
        • False: Do not set agents to Not Ready state


.PARAMETER WrapupDispostionName

    Name of disposition automatically set for the call if the timeout is reached

.PARAMETER WrapupReasonCodeName
    
    Not Ready reason code for agents who are automatically placed in Not Ready state after reaching the timeout

.PARAMETER WrapupTimerDays

    Number of Days used on wrap up timer

.PARAMETER WrapupTimerHours

    Number of Hours used on wrap up timer

.PARAMETER WrapupTimerMinutes

    Number of Minutes used on wrap up timer

.PARAMETER WrapupTimerSeconds
    
    Number of Seconds used on wrap up timer


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9InboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls" -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 10
    
    # Creates new inbound campaign with minimum number of required parameters

.EXAMPLE
    
    New-Five9InboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls" -Mode: ADVANCED -ProfileName "Cold-Calls-Profile" -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 50 `
                             -CallWrapupEnabled $true -WrapupAgentNotReady $true -WrapupTimerMinutes 2 -WrapupTimerSeconds 30
    
    # Creates new inbound campaign in advanced mode, and enables call wrap up timer


 
#>
function New-Five9InboundCampaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][ValidateSet('BASIC', 'ADVANCED')][string]$Mode = 'BASIC',
        [Parameter(Mandatory=$false)][string]$ProfileName,
        [Parameter(Mandatory=$true)][string]$IvrScriptName,
        [Parameter(Mandatory=$true)][int]$MaxNumOfLines,

        [Parameter(Mandatory=$false)][bool]$TrainingMode,

        [Parameter(Mandatory=$false)][bool]$AutoRecord,
        [Parameter(Mandatory=$false)][bool]$UseFtp,
        [Parameter(Mandatory=$false)][bool]$RecordingNameAsSid,
        [Parameter(Mandatory=$false)][string]$FtpHost,
        [Parameter(Mandatory=$false)][string]$FtpUser,
        [Parameter(Mandatory=$false)][string]$FtpPassword,

        [Parameter(Mandatory=$false)][bool]$CallWrapupEnabled,
        [Parameter(Mandatory=$false)][bool]$WrapupAgentNotReady,
        [Parameter(Mandatory=$false)][string]$WrapupDispostionName,
        [Parameter(Mandatory=$false)][string]$WrapupReasonCodeName,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerDays,
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$WrapupTimerHours,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerMinutes,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerSeconds

    )

    $inboundCampaign = New-Object PSFive9Admin.inboundCampaign

    $inboundCampaign.type = "INBOUND"
    $inboundCampaign.typeSpecified = $true

    $inboundCampaign.name = $Name

    $inboundCampaign.mode = $Mode
    $inboundCampaign.modeSpecified = $true


    $inboundCampaign.defaultIvrSchedule = New-Object PSFive9Admin.inboundIvrScriptSchedule
    $inboundCampaign.defaultIvrSchedule.ivrSchedule = New-Object PSFive9Admin.ivrScriptSchedule
    $inboundCampaign.defaultIvrSchedule.ivrSchedule.scriptName = $IvrScriptName


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

    if ($PSBoundParameters.Keys -contains 'RecordingNameAsSid')
    {
        $inboundCampaign.recordingNameAsSid = $RecordingNameAsSid
        $inboundCampaign.recordingNameAsSidSpecified = $true
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

        if ($PSBoundParameters.Keys -contains 'WrapupDispostionName')
        {
            $inboundCampaign.callWrapup.dispostionName = $WrapupDispostionName
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

    if ($PSBoundParameters.Keys -contains 'AutoRecord')
    {
        $inboundCampaign.autoRecord = $AutoRecord
        $inboundCampaign.autoRecordSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'TrainingMode')
    {
        $inboundCampaign.trainingMode = $TrainingMode
        $inboundCampaign.trainingModeSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'UseFtp')
    {
        $inboundCampaign.useFtp = $UseFtp
        $inboundCampaign.useFtpSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'FtpHost')
    {
        $inboundCampaign.FtpHost = $FtpHost
    }
    
    if ($PSBoundParameters.Keys -contains 'FtpUser')
    {
        $inboundCampaign.ftpUser = $FtpUser
    }

    if ($PSBoundParameters.Keys -contains 'FtpPassword')
    {
        $inboundCampaign.ftpPassword = $FtpPassword
    }



    $response = $Five9AdminClient.createInboundCampaign($inboundCampaign)


    return $response

}

