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
    New-Five9outboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls" -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 10
    
    # Creates new inbound campaign with minimum number of required parameters

.EXAMPLE
    
    New-Five9outboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls" -Mode: ADVANCED -ProfileName "Cold-Calls-Profile" -IvrScriptName "Cold-Calls-IVR" -MaxNumOfLines 50 `
                             -CallWrapupEnabled $true -WrapupAgentNotReady $true -WrapupTimerMinutes 2 -WrapupTimerSeconds 30
    
    # Creates new inbound campaign in advanced mode, and enables call wrap up timer


 
#>
function New-Five9OutboundCampaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,


        # General Tab
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxQueueTimeMinutes = 0,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxQueueTimeSeconds = 1,
        [Parameter(Mandatory=$false)][bool]$UseTelemarketingMaxQueTime,

        [Parameter(Mandatory=$false)][ValidateSet('PREDICTIVE', 'PROGRESSIVE', 'PREVIEW', 'POWER')][string]$DialingMode,

        [Parameter(Mandatory=$false)][bool]$ShowOutOfNumbersAlert = $true,
        [Parameter(Mandatory=$false)][bool]$UseDnisAsAni,
        [Parameter(Mandatory=$false)][bool]$TrainingMode,
        [Parameter(Mandatory=$false)][ValidateSet('BASIC', 'ADVANCED')][string]$Mode = 'BASIC',
        [Parameter(Mandatory=$false)][string]$ProfileName,
        [Parameter(Mandatory=$false)][ValidateSet('LongestReadyTime', 'LongestReadyTimeExcludeMC', 'RoundRobin', 'MinCallsHandled', 'MinHandleTime')][string]$DistributionAlgorithm = 'LongestReadyTime',
        [Parameter(Mandatory=$false)][ValidateSet('minutes15', 'minutes30', 'minutes60', 'hours8', 'hours24', 'thisDay')][string]$DistributionTimeFrame = 'minutes15', # only used for "Min" algorithms
        [Parameter(Mandatory=$false)][bool]$CallWrapupEnabled,
        [Parameter(Mandatory=$false)][bool]$WrapupAgentNotReady,
        [Parameter(Mandatory=$false)][string]$WrapupDispostionName,
        [Parameter(Mandatory=$false)][string]$WrapupReasonCodeName,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerDays,
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$WrapupTimerHours,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerMinutes,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerSeconds,

        # Recording Tab
        [Parameter(Mandatory=$false)][bool]$AutoRecord,
        [Parameter(Mandatory=$false)][bool]$RecordingNameAsSid,
        [Parameter(Mandatory=$false)][bool]$UseFtp,
        [Parameter(Mandatory=$false)][string]$FtpHost,
        [Parameter(Mandatory=$false)][string]$FtpUser,
        [Parameter(Mandatory=$false)][string]$FtpPassword,


        # Dialing Options Tab

        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$DurationBeforeRedialHours = 8,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$DurationBeforeRedialMinutes = 0,

        # Power
        [Parameter(Mandatory=$false)][ValidateRange(1.0,10.0)][double]$CallsAgentRatio,

        # Preview
        [Parameter(Mandatory=$false)][ValidateSet('Unlimited_Preview_Time', 'Limited_Preview_Time', 'No_Preview_Time')][string]$PreviewMode,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxPreviewTimeMinutes, # only used when PreviewMode is Limited_Preview_Time
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxPreviewTimeSeconds, # nly used when PreviewMode is Limited_Preview_Time
        [Parameter(Mandatory=$false)][ValidateSet('Dial_Number', 'Set_Agent_Not_Ready')][string]$MaxPreviewTimeAction, # nly used when PreviewMode is Limited_Preview_Time

        # Others
        [Parameter(Mandatory=$false)][ValidateSet('VERTICAL_DIALING', 'LIST_PENETRATION', 'EXTENDED_STRATEGY')][string]$ListDialingMode,
        [Parameter(Mandatory=$false)][bool]$MonitorDroppedCalls,
        [Parameter(Mandatory=$false)][ValidateRange(0,10.0)][float]$MaxDroppedCallsPercentage, # only used when MonitorDroppedCalls is $true
        [Parameter(Mandatory=$false)][ValidateSet('NO_ANALYSIS', 'FAX_ONLY', 'FAX_AND_ANSWERING_MACHINE')][string]$CallAnalysisMode,
        [Parameter(Mandatory=$false)][ValidateRange(2,10.0)][float]$VoiceDetectionLevel = 2.0, # only used when CallAnalysisMode is FAX_AND_ANSWERING_MACHINE // 20 = 2sec 100 = 10sec

        [Parameter(Mandatory=$false)][ValidateSet('DROP_CALL', 'PLAY_PROMPT', 'START_IVR_SCRIPT')][string]$AnswerMachineAction,
        [Parameter(Mandatory=$false)][string]$AnswerMachineIVRScriptName, #only used when ActionOnAnswerMachine is START_IVR_SCRIPT
        [Parameter(Mandatory=$false)][string]$AnswerMachinePromptName, #only used when ActionOnAnswerMachine is PLAY_PROMPT
        [Parameter(Mandatory=$false)][ValidateRange(0,60.0)][int]$AnswerMachineMaxWaitSeconds, #only used when ActionOnAnswerMachine is PLAY_PROMPT

        [Parameter(Mandatory=$false)][ValidateSet('DROP_CALL', 'PLAY_PROMPT', 'START_IVR_SCRIPT')][string]$QueueExpirationAction,
        [Parameter(Mandatory=$false)][string]$QueueExpirationIVRScriptName, #only used when ActionOnAnswerMachine is START_IVR_SCRIPT
        [Parameter(Mandatory=$false)][string]$QueueExpirationPromptName #only used when ActionOnAnswerMachine is PLAY_PROMPT

    )


    $outboundCampaign = New-Object PSFive9Admin.outboundCampaign

    $outboundCampaign.type = "OUTBOUND"
    $outboundCampaign.typeSpecified = $true

    $outboundCampaign.name = $Name


    $outboundCampaign.maxQueueTime = New-Object PSFive9Admin.timer
    if ($UseTelemarketingMaxQueTime -eq $true)
    {
        $outboundCampaign.maxQueueTime.seconds = 1
        $outboundCampaign.useTelemarketingMaxQueTimeEq1 = $true
        $outboundCampaign.useTelemarketingMaxQueTimeEq1Specified = $true

    }
    else
    {
        $outboundCampaign.maxQueueTime.minutes = $MaxQueueTimeMinutes
        $outboundCampaign.maxQueueTime.seconds = $MaxQueueTimeSeconds
    }

    # this property HAS to be set no matter what the dialing mode is set to
    $outboundCampaign.actionOnQueueExpiration = New-Object PSFive9Admin.campaignDialingAction
    $outboundCampaign.actionOnQueueExpiration.actionType = "DROP_CALL"
    $outboundCampaign.actionOnQueueExpiration.actionTypeSpecified = $true

    $outboundCampaign.actionOnAnswerMachine = New-Object PSFive9Admin.campaignDialingAction
    $outboundCampaign.actionOnAnswerMachine.actionType = "DROP_CALL"
    $outboundCampaign.actionOnAnswerMachine.actionTypeSpecified = $true


    if ($PSBoundParameters.Keys -contains 'DialingMode')
    {
        $outboundCampaign.dialingMode = $DialingMode
        $outboundCampaign.dialingModeSpecified = $true
    }
    
    if ($PSBoundParameters.Keys -contains 'Description')
    {
        $outboundCampaign.description = $Description
    }


    $outboundCampaign.noOutOfNumbersAlert = $ShowOutOfNumbersAlert
    $outboundCampaign.noOutOfNumbersAlertSpecified = $true
    if ($ShowOutOfNumbersAlert -eq $false)
    {
        $outboundCampaign.noOutOfNumbersAlert = $true
    }

    if ($PSBoundParameters.Keys -contains 'UseDnisAsAni')
    {
        $outboundCampaign.dnisAsAni = $UseDnisAsAni
        $outboundCampaign.dnisAsAniSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'TrainingMode')
    {
        $outboundCampaign.trainingMode = $TrainingMode
        $outboundCampaign.trainingModeSpecified = $true
    }

    $outboundCampaign.mode = $Mode
    $outboundCampaign.modeSpecified = $true

    if ($Mode -eq 'ADVANCED')
    {
        # if type is advanced, must also provide a campaign profile name
        if ($PSBoundParameters.Keys -notcontains 'ProfileName')
        {
            throw "Campaign Mode set as ""ADVANCED"", but no profile name was provided. Try again including the -ProfileName parameter."
            return
        }

        $outboundCampaign.profileName = $ProfileName

    }


    if ($PSBoundParameters.Keys -contains 'DistributionAlgorithm')
    {
        $outboundCampaign.distributionAlgorithm = $DistributionAlgorithm
        $outboundCampaign.distributionAlgorithmSpecified = $true

        if ($DistributionAlgorithm -match 'MinCallsHandled|MinHandleTime')
        {
            if ($PSBoundParameters.Keys -notcontains 'DistributionTimeFrame')
            {
                throw "Distribution Algorithm set as ""$DistributionAlgorithm"", but no Distribution Time Frame was provided. Try again including the -DistributionTimeFrame parameter."
                return
            }

            $outboundCampaign.distributionTimeFrame = $DistributionTimeFrame
            $outboundCampaign.distributionTimeFrameSpecified = $true
        }
    }


    if ($CallWrapupEnabled -eq $true)
    {
        $outboundCampaign.callWrapup = New-Object PSFive9Admin.campaignCallWrapup
        $outboundCampaign.callWrapup.enabled = $true
        $outboundCampaign.callWrapup.enabledSpecified = $true

        if ($WrapupAgentNotReady -eq $true)
        {
            $outboundCampaign.callWrapup.agentNotReady = $true
            $outboundCampaign.callWrapup.agentNotReadySpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'WrapupDispostionName')
        {
            $outboundCampaign.callWrapup.dispostionName = $WrapupDispostionName
        }

        if ($PSBoundParameters.Keys -contains 'WrapupReasonCodeName')
        {
            $outboundCampaign.callWrapup.reasonCodeName = $WrapupReasonCodeName
        }

        $outboundCampaign.callWrapup.timeout = New-Object PSFive9Admin.timer
        $outboundCampaign.callWrapup.timeout.days = $WrapupTimerDays
        $outboundCampaign.callWrapup.timeout.hours = $WrapupTimerHours
        $outboundCampaign.callWrapup.timeout.minutes = $WrapupTimerMinutes
        $outboundCampaign.callWrapup.timeout.seconds = $WrapupTimerSeconds

    }
    



    if ($PSBoundParameters.Keys -contains 'AutoRecord')
    {
        $outboundCampaign.autoRecord = $AutoRecord
        $outboundCampaign.autoRecordSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'RecordingNameAsSid')
    {
        $outboundCampaign.recordingNameAsSid = $RecordingNameAsSid
        $outboundCampaign.recordingNameAsSidSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'UseFtp')
    {
        $outboundCampaign.useFtp = $UseFtp
        $outboundCampaign.useFtpSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'FtpHost')
    {
        $outboundCampaign.ftpHost = $FtpHost
    }
    
    if ($PSBoundParameters.Keys -contains 'FtpUser')
    {
        $outboundCampaign.ftpUser = $FtpUser
    }

    if ($PSBoundParameters.Keys -contains 'FtpPassword')
    {
        $outboundCampaign.ftpPassword = $FtpPassword
    }


    if ($PSBoundParameters.Keys -contains 'CallsAgentRatio')
    {
        $outboundCampaign.callsAgentRatio = $CallsAgentRatio
        $outboundCampaign.callsAgentRatioSpecified = $true
    }


    $outboundCampaign.CRMRedialTimeout = New-Object PSFive9Admin.timer
    $outboundCampaign.CRMRedialTimeout.hours = $DurationBeforeRedialHours
    $outboundCampaign.CRMRedialTimeout.minutes = $DurationBeforeRedialMinutes
    

    if ($DialingMode -eq 'PREVIEW')
    {
        if ($PreviewMode -eq 'No_Preview_Time')
        {
            $outboundCampaign.previewDialImmediately = $true
            $outboundCampaign.previewDialImmediatelySpecified = $true
        }
        elseif ($PreviewMode -eq 'Unlimited_Preview_Time')
        {
            $outboundCampaign.limitPreviewTime = $false
            $outboundCampaign.limitPreviewTimeSpecified = $true
        }
        elseif ($PreviewMode -eq 'Limited_Preview_Time')
        {
            $outboundCampaign.limitPreviewTime = $true
            $outboundCampaign.limitPreviewTimeSpecified = $true

            $outboundCampaign.maxPreviewTime = New-Object PSFive9Admin.timer
            $outboundCampaign.maxPreviewTime.minutes = $MaxPreviewTimeMinutes
            $outboundCampaign.maxPreviewTime.seconds = $MaxPreviewTimeSeconds

            if ($MaxPreviewTimeAction -eq 'Dial_Number')
            {
                $outboundCampaign.dialNumberOnTimeout = $true
                $outboundCampaign.dialNumberOnTimeoutSpecified = $true
            }
            elseif ($MaxPreviewTimeAction -eq 'Set_Agent_Not_Ready')
            {
                $outboundCampaign.dialNumberOnTimeout = $false
                $outboundCampaign.dialNumberOnTimeoutSpecified = $true
            }

            
        }
    }

    if ($PSBoundParameters.Keys -contains 'ListDialingMode')
    {
        $outboundCampaign.listDialingMode = $ListDialingMode
        $outboundCampaign.listDialingModeSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'MonitorDroppedCalls')
    {
        $outboundCampaign.monitorDroppedCalls = $MonitorDroppedCalls
        $outboundCampaign.monitorDroppedCallsSpecified = $true
    }
    

    if ($PSBoundParameters.Keys -contains 'MaxDroppedCallsPercentage')
    {
        $outboundCampaign.maxDroppedCallsPercentage = $MaxDroppedCallsPercentage
        $outboundCampaign.maxDroppedCallsPercentageSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'CallAnalysisMode')
    {
        $outboundCampaign.callAnalysisMode = $CallAnalysisMode
        $outboundCampaign.callAnalysisModeSpecified = $true

        if ($CallAnalysisMode -eq 'FAX_AND_ANSWERING_MACHINE')
        {
            # the api wants a number between 20 and 100.
            # 20 = 2sec / 100 = 10sec. 
            # we'll multipy a smaller number by 10 to make this less confusing,. i.e. 3.5 * 10 = 35
            $outboundCampaign.analyzeLevel = ($VoiceDetectionLevel * 10)
            $outboundCampaign.analyzeLevelSpecified = $true
        }
    }


    if ($PSBoundParameters.Keys -contains 'AnswerMachineAction')
    {
        if ($AnswerMachineAction -eq 'PLAY_PROMPT')
        {
            $outboundCampaign.actionOnAnswerMachine.actionType = "PLAY_PROMPT"
            $outboundCampaign.actionOnAnswerMachine.actionArgument = $AnswerMachinePromptName
            $outboundCampaign.actionOnAnswerMachine.maxWaitTime = New-Object PSFive9Admin.timer
            $outboundCampaign.actionOnAnswerMachine.maxWaitTime.seconds = $AnswerMachineMaxWaitSeconds
        }
        elseif ($AnswerMachineAction -eq 'START_IVR_SCRIPT')
        {
            $outboundCampaign.actionOnAnswerMachine.actionType = "START_IVR_SCRIPT"
            $outboundCampaign.actionOnAnswerMachine.actionArgument = $AnswerMachineIVRScriptName
        }

    }

    if ($PSBoundParameters.Keys -contains 'QueueExpirationAction')
    {
        if ($AnswerMachineAction -eq 'PLAY_PROMPT')
        {
            $outboundCampaign.actionOnQueueExpiration.actionType = "PLAY_PROMPT"
            $outboundCampaign.actionOnQueueExpiration.actionArgument = $QueueExpirationPromptName
        }
        elseif ($AnswerMachineAction -eq 'START_IVR_SCRIPT')
        {
            $outboundCampaign.actionOnQueueExpiration.actionType = "START_IVR_SCRIPT"
            $outboundCampaign.actionOnQueueExpiration.actionArgument = $QueueExpirationIVRScriptName
        }

    }

    $response = $Five9AdminClient.createOutboundCampaign($outboundCampaign)


    return $response

}

