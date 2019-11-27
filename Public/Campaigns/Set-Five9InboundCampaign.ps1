<#
.SYNOPSIS
    
    Function used to create a new inbound campaign in Five9
 
.PARAMETER Name

    Name of new campaign

.PARAMETER Description

     Description of new campaign

.PARAMETER State

    State of new campaign. 
    Options are: 
        • NOT_RUNNING - Campaign not currently active
        • STARTING - Campaign being initialized
        • RUNNING - Campaign currently active
        • STOPPING - Campaign currently stopping
        • RESETTING - Temporary state of an outbound campaign that is returning to its initial state. All dialing results of the outbound campaign are cleared so that all records can be redialed


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

.PARAMETER UseWrapupTimer

    Enables time limit for agents in wrap-up mode

.PARAMETER UseWrapupTimer

    Whether this disposition uses a Wrapup timer

.PARAMETER WrapupTimerDays

    Number of Days
    Only used when -UseWrapupTimer is set to "True"

.PARAMETER WrapupTimerHours

    Number of Hours
    Only used when -UseWrapupTimer is set to "True"

.PARAMETER WrapupTimerMinutes

    Number of Minutes
    Only used when -UseWrapupTimer is set to "True"

.PARAMETER WrapupTimerSeconds
    
    Number of Seconds
    Only used when -UseWrapupTimer is set to "True"


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9InboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls" -State: RUNNING -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 10
    
    # Creates new inbound campaign with minimum number of required parameters

.EXAMPLE
    
    New-Five9InboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls" -State RUNNING -Mode: ADVANCED -ProfileName "Cold-Calls-Profile" -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 50 `
                             -CallWrapupEnabled $true -WrapupAgentNotReady $true -UseWrapupTimer $true -WrapupTimerMinutes 2 -WrapupTimerSeconds 30
    
    # Creates new inbound campaign in advanced mode, and enabled call wrap up timer


 
#>
function Set-Five9InboundCampaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$NewName,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$true)][ValidateSet('NOT_RUNNING', 'STARTING', 'RUNNING', 'STOPPING', 'RESETTING')][string]$State,
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
        [Parameter(Mandatory=$false)][bool]$UseWrapupTimer,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerDays,
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$WrapupTimerHours,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerMinutes,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerSeconds

    )

    $campaignToModify = $null
    try
    {
        $campaignToModify = $Five9AdminClient.getInboundCampaign($Name) 
    }
    catch
    {

    }
    
    if ($campaignToModify.Count -gt 1)
    {
        throw "Multiple campaigns were found using query: ""$Name"". Please try using the exact name of the campaign you're trying to modify."
        return
    }

    if ($campaignToModify -eq $null)
    {
        throw "Cannot find a campaign with name: ""$Name"". Remember that Name is case sensitive."
        return
    }

    $campaignToModify = $campaignToModify | select -First 1

    $campaignToModify = New-Object PSFive9Admin.inboundCampaign

    $campaignToModify.type = "INBOUND"
    $campaignToModify.typeSpecified = $true

    $campaignToModify.name = $Name

    $campaignToModify.state = $State
    $campaignToModify.stateSpecified = $true

    $campaignToModify.mode = $Mode
    $campaignToModify.modeSpecified = $true


    $campaignToModify.defaultIvrSchedule = New-Object PSFive9Admin.inboundIvrScriptSchedule
    $campaignToModify.defaultIvrSchedule.ivrSchedule = New-Object PSFive9Admin.ivrScriptSchedule
    $campaignToModify.defaultIvrSchedule.ivrSchedule.scriptName = $IvrScriptName


    if ($Mode -eq 'ADVANCED')
    {
        # if type is advanced, must also provide a campaign profile name
        if ($PSBoundParameters.Keys -notcontains 'ProfileName')
        {
            throw "Campaign Mode set as ""ADVANCED"", but no profile name was provided. Try again including the -ProfileName parameter."
            return
        }

        $campaignToModify.profileName = $ProfileName

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

    if ($PSBoundParameters.Keys -contains 'MaxNumOfLines')
    {
        $campaignToModify.MaxNumOfLines = $MaxNumOfLines
        $campaignToModify.maxNumOfLinesSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'Description')
    {
        $campaignToModify.description = $Description
    }

    if ($CallWrapupEnabled -eq $true)
    {
        $campaignToModify.callWrapup = New-Object PSFive9Admin.campaignCallWrapup
        $campaignToModify.callWrapup.enabled = $true
        $campaignToModify.callWrapup.enabledSpecified = $true

        if ($WrapupAgentNotReady -eq $true)
        {
            $campaignToModify.callWrapup.agentNotReady = $true
            $campaignToModify.callWrapup.agentNotReadySpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'WrapupDispostionName')
        {
            $campaignToModify.callWrapup.dispostionName = $WrapupDispostionName
        }

        if ($PSBoundParameters.Keys -contains 'WrapupReasonCodeName')
        {
            $campaignToModify.callWrapup.reasonCodeName = $WrapupReasonCodeName
        }

        if ($UseWrapupTimer -eq $true)
        {

            if ($WrapupTimerDays -lt 1 -and $WrapupTimerHours -lt 1 -and $WrapupTimerMinutes -lt 1)
            {
                throw "When -UseWrapupTimer is set to True, the total -WrapupTimer<unit> values must be set to at least 1 minute. For example, to set wrapup to 2.5 minutes, use: -WrapupTimerHours 2 -WrapupTimerSeconds 30"
                return
            }

            $campaignToModify.callWrapup.timeout = New-Object PSFive9Admin.timer
            $campaignToModify.callWrapup.timeout.days = $WrapupTimerDays
            $campaignToModify.callWrapup.timeout.hours = $WrapupTimerHours
            $campaignToModify.callWrapup.timeout.minutes = $WrapupTimerMinutes
            $campaignToModify.callWrapup.timeout.seconds = $WrapupTimerSeconds

        }

    }

    if ($PSBoundParameters.Keys -contains 'AutoRecord')
    {
        $campaignToModify.autoRecord = $AutoRecord
        $campaignToModify.autoRecordSpecified = $true
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
        $campaignToModify.FtpHost = $FtpHost
    }
    
    if ($PSBoundParameters.Keys -contains 'FtpUser')
    {
        $campaignToModify.ftpUser = $FtpUser
    }

    if ($PSBoundParameters.Keys -contains 'FtpPassword')
    {
        $campaignToModify.ftpPassword = $FtpPassword
    }


    $response = $Five9AdminClient.createInboundCampaign($campaignToModify)

    return $response

}

