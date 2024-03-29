function New-Five9OutboundCampaign
{
    <#
    .SYNOPSIS
    
        Function used to create a new outbound campaign in Five9

    .EXAMPLE
    
        New-Five9OutboundCampaign -Name "Hot-Leads"

        #Creates a new outbound campaign using all default values

    .EXAMPLE
        New-Five9OutboundCampaign -Name "Hot-Leads" -DialingMode: PREVIEW -PreviewMode: Limited_Preview_Time -MaxPreviewTimeAction: Dial_Number -MaxPreviewTimeMinutes 1 -MaxPreviewTimeSeconds 30

        #Creates a new outbound campaign using in preview mode where calls are made after previewing for 1 minute and 30 seconds

    .EXAMPLE
        New-Five9OutboundCampaign -Name "Hot-Leads" -UseTelemarketingMaxQueTime $true -DialingMode: POWER -CallsAgentRatio 2 -QueueExpirationAction: DROP_CALL

        #Creates a new outbound campaign in "Power" using a 2:1 agent ratio

    .EXAMPLE

        New-Five9OutboundCampaign -Name "Hot-Leads" -UseTelemarketingMaxQueTime $true -DialingMode: PROGRESSIVE `
                                  -CallsAgentRatio 5 -CallAnalysisMode: FAX_AND_ANSWERING_MACHINE -VoiceDetectionLevel 3.5 `
                                  -AnswerMachineAction: START_IVR_SCRIPT -AnswerMachineIVRScriptName "Answer-Machine-IVR" `
                                  -QueueExpirationAction: START_IVR_SCRIPT -QueueExpirationIVRScriptName "Abandon-Call-IVR"

        #Creates a new outbound campaign in "Progressive" using a 5:1 agent ratio. Also enables answering machine detection 
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # 
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Description of new campaign
        [Parameter(Mandatory=$false)][string]$Description,

        # Maximum time allowed for calls in a queue (minutes)
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxQueueTimeMinutes = 0,

        # Maximum time allowed for calls in a queue (seconds)
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxQueueTimeSeconds = 1,

        # Sets the max queue time to 1 second
        [Parameter(Mandatory=$false)][bool]$UseTelemarketingMaxQueTime,

        <#
        Sets list dialing mode

        Options are:
            • PREDICTIVE
                Depending on campaign statistics, dials at a variable calls-to-agent ratio. For maximum agent use, predicts agent availability to begin dialing calls before an agent becomes ready for calls
            • PROGRESSIVE
                Depending on campaign statistics, dials at a variable calls-to-agent ratio when an agent becomes available
            • PREVIEW
                Enables the agent to review the contact details before dialing or skipping the record
            • POWER
                Dials at a fixed calls-to-agent ratio (1- to-1 or higher) when an agent becomes available
        #>
        [Parameter(Mandatory=$false)][ValidateSet('PREDICTIVE', 'PROGRESSIVE', 'PREVIEW', 'POWER')][string]$DialingMode,

        # When an outbound campaign runs out of numbers to dial, whether to turn off notification messages to administrators and supervisors that the campaign is no longer dialing because the lists are complete
        [Parameter(Mandatory=$false)][bool]$ShowOutOfNumbersAlert = $true,

        <#
        When transferring calls to third parties, whether to override the default DNIS of the domain by using the contact’s phone number (ANI) as the DNIS (caller ID)

        Options are:
            • True: Override the default DNIS
            • False: Do not override the default DNIS
        #>
        [Parameter(Mandatory=$false)][bool]$UseDnisAsAni,

        # Whether the campaign is in training mode
        [Parameter(Mandatory=$false)][bool]$TrainingMode,

        <#
        Mode of new campaign. If not specified default set to BASIC.

        Options are:
            • BASIC (Default) -  Campaign with default settings without a campaign profile
            • ADVANCED - Campaign with a campaign profile specified in the profileName parameter
        #>
        [Parameter(Mandatory=$false)][ValidateSet('BASIC', 'ADVANCED')][string]$Mode = 'BASIC',

        # Campaign profile name. Applies only to the advanced campaign mode
        [Parameter(Mandatory=$false)][string]$ProfileName,

        <#
        Method used by the ACD to transfer calls to agents

        Options are:
            • LongestReadyTime
            • LongestReadyTimeExcludeMC
            • RoundRobin
            • MinCallsHandled
            • MinHandleTime
        #>
        [Parameter(Mandatory=$false)][ValidateSet('LongestReadyTime', 'LongestReadyTimeExcludeMC', 'RoundRobin', 'MinCallsHandled', 'MinHandleTime')][string]$DistributionAlgorithm = 'LongestReadyTime',

        # Time intervals used by DistributionAlgorithm. Only used when DistributionAlgorithm is set to MinCallsHandled or MinHandleTime
        [Parameter(Mandatory=$false)][ValidateSet('minutes15', 'minutes30', 'minutes60', 'hours8', 'hours24', 'thisDay')][string]$DistributionTimeFrame = 'minutes15',

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
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$WrapupTimerSeconds,

        # Whether to record all calls of the campaign
        [Parameter(Mandatory=$false)][bool]$AutoRecord,

        # For FTP transfer, whether to use the session ID as the recording name
        [Parameter(Mandatory=$false)][bool]$RecordingNameAsSid,

        # Whether to use FTP to transfer recordings.
        # NOTE: SFTP must be enabled in the Java Admin console
        [Parameter(Mandatory=$false)][bool]$UseFtp,

        # Host name of the FTP server
        [Parameter(Mandatory=$false)][string]$FtpHost,

        # Username of the FTP server
        [Parameter(Mandatory=$false)][string]$FtpUser,

        # Password of the FTP server
        [Parameter(Mandatory=$false)][string]$FtpPassword,

        # Minimum time before redialing a contact record after all numbers for the contact record have been dialed or skipped (hours)
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$DurationBeforeRedialHours = 8,

        # Minimum time before redialing a contact record after all numbers for the contact record have been dialed or skipped (minutes)
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$DurationBeforeRedialMinutes = 0,

        # For campaigns in the predictive mode, number of phone numbers dialed for an agent ready for a new call
        [Parameter(Mandatory=$false)][ValidateRange(1.0,10.0)][double]$CallsAgentRatio,

        <#
        Mode for whether agents are allowed to preview calls before their dialed

        Options are: 
            • Unlimited_Preview_Time
                Allow agents to preview the contact number for an unlimited time
            • Limited_Preview_Time
                Dial contact number after maxPreviewTime is reached
            • No_Preview_Time
                Automatically dial the number without waiting for an action from the agent
        #>
        [Parameter(Mandatory=$false)][ValidateSet('Unlimited_Preview_Time', 'Limited_Preview_Time', 'No_Preview_Time')][string]$PreviewMode,

        # Minutes duration until expiration of the preview time
        # Only used when PreviewMode is Limited_Preview_Time
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxPreviewTimeMinutes = 2,

        # Seconds duration until expiration of the preview time
        # Only used when PreviewMode is Limited_Preview_Time
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxPreviewTimeSeconds = 0,

        <# 
        Action to take when MaxPreviewTime expires

        Options are:
            • Dial_Number
            • Set_Agent_Not_Ready
        #>
        [Parameter(Mandatory=$false)][ValidateSet('Dial_Number', 'Set_Agent_Not_Ready')][string]$MaxPreviewTimeAction,

        <#
        Sets list dialing mode

        Options are:
            • VERTICAL_DIALING
                Dialer attempts to call all numbers in a CRM record before proceeding to the next record.
            • LIST_PENETRATION
                Dialer attempts to call all numbers in a column before proceeding to the next column
            • EXTENDED_STRATEGY
                Dialer attempts to call numbers in a list in order of importance. For example, until a contact is reached, numbers that are more important are redialed sooner and more often than those that are not
        #>
        [Parameter(Mandatory=$false)][ValidateSet('VERTICAL_DIALING', 'LIST_PENETRATION', 'EXTENDED_STRATEGY')][string]$ListDialingMode,

        # Whether to keep track of the dropped call percentage of the campaign
        [Parameter(Mandatory=$false)][bool]$MonitorDroppedCalls,

        # Only used when MonitorDroppedCalls is True
        [Parameter(Mandatory=$false)][ValidateRange(0,10.0)][float]$MaxDroppedCallsPercentage,

        <#
        Sets type of call analysis that will take place when a call is answered

        Options are:
            • NO_ANALYSIS
                No detection is attempted
            • FAX_ONLY
                Fax detection is attempted
            • FAX_AND_ANSWERING_MACHINE
                Fax and answering machine detection are attempted
        #> 
        [Parameter(Mandatory=$false)][ValidateSet('NO_ANALYSIS', 'FAX_ONLY', 'FAX_AND_ANSWERING_MACHINE')][string]$CallAnalysisMode,

        # Voice detection level for an answering machine. For example: if set to 3.5, voice detection will take 3.5 seconds to try and determine whether a real person or an answering machine has answered the call.
        # Only used when CallAnalysisMode is FAX_AND_ANSWERING_MACHINE
        [Parameter(Mandatory=$false)][ValidateRange(2,10.0)][float]$VoiceDetectionLevel = 2.0,

        <#
        Action to take when the answering machine is detected.

        Options are:
            • DROP_CALL
                Call is dropped
            • PLAY_PROMPT
                Prompt is played as specified by -AnswerMachinePromptName
            • START_IVR_SCRIPT
                IVR script started as specified by -AnswerMachineIVRScriptName
         #>
        [Parameter(Mandatory=$false)][ValidateSet('DROP_CALL', 'PLAY_PROMPT', 'START_IVR_SCRIPT')][string]$AnswerMachineAction,

        # Name of IVR script to be started when answering machine is detected
        # Only used when ActionOnAnswerMachine is START_IVR_SCRIPT
        [Parameter(Mandatory=$false)][string]$AnswerMachineIVRScriptName,

        # Name of prompt to be played when answering machine is detected
        # Only used when ActionOnAnswerMachine is PLAY_PROMPT
        [Parameter(Mandatory=$false)][string]$AnswerMachinePromptName,

        # Number of seconds to be waited before prompt is played after answering machine is detected
        # Only used when ActionOnAnswerMachine is PLAY_PROMPT
        [Parameter(Mandatory=$false)][ValidateRange(0,60.0)][int]$AnswerMachineMaxWaitSeconds = 20,

        <#
        Action to take when the maximum queue time expires, which occurs when no agent is available to take a call

        Options are:
            • DROP_CALL
                Call is dropped
            • PLAY_PROMPT
                Prompt is played as specified by -QueueExpirationPromptName
            • START_IVR_SCRIPT
                IVR script started as specified by -QueueExpirationIVRScriptName
        #>
        [Parameter(Mandatory=$false)][ValidateSet('DROP_CALL', 'PLAY_PROMPT', 'START_IVR_SCRIPT')][string]$QueueExpirationAction,

        # Name of IVR script to be started when max queue time expires
        # Only used when QueueExpirationAction is START_IVR_SCRIPT
        [Parameter(Mandatory=$false)][string]$QueueExpirationIVRScriptName,

        # Name of prompt to be played when max queue time expires
        # Only used when QueueExpirationAction is PLAY_PROMPT
        [Parameter(Mandatory=$false)][string]$QueueExpirationPromptName,

        # Whether to use list dialing ratios, which enable multiple lists to be dialed at specified frequencies
        [Parameter(Mandatory=$false)][bool]$EnableListDialingRatios


    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

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
        }

        if ($PSBoundParameters.Keys -contains 'DistributionTimeFrame')
        {
            $outboundCampaign.distributionTimeFrame = $DistributionTimeFrame
            $outboundCampaign.distributionTimeFrameSpecified = $true
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

            if ($PSBoundParameters.Keys -contains 'WrapupDispositionName')
            {
                $outboundCampaign.callWrapup.dispostionName = $WrapupDispositionName
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
                if ($PSBoundParameters.Keys -notcontains 'AnswerMachinePromptName')
                {
                    throw "When -AnswerMachineAction is set to ""PLAY_PROMPT"", a prompt name must be provided using -AnswerMachinePromptName."
                    return
                }

                $outboundCampaign.actionOnAnswerMachine.actionType = "PLAY_PROMPT"
                $outboundCampaign.actionOnAnswerMachine.actionArgument = $AnswerMachinePromptName
                $outboundCampaign.actionOnAnswerMachine.maxWaitTime = New-Object PSFive9Admin.timer
                $outboundCampaign.actionOnAnswerMachine.maxWaitTime.seconds = $AnswerMachineMaxWaitSeconds
            }
            elseif ($AnswerMachineAction -eq 'START_IVR_SCRIPT')
            {
                if ($PSBoundParameters.Keys -notcontains 'AnswerMachineIVRScriptName')
                {
                    throw "When -AnswerMachineAction is set to ""START_IVR_SCRIPT"", an IVR script name must be provided using -AnswerMachineIVRScriptName."
                    return
                }

                $outboundCampaign.actionOnAnswerMachine.actionType = "START_IVR_SCRIPT"
                $outboundCampaign.actionOnAnswerMachine.actionArgument = $AnswerMachineIVRScriptName
            }

        }

        if ($PSBoundParameters.Keys -contains 'QueueExpirationAction')
        {
            if ($QueueExpirationAction -eq 'PLAY_PROMPT')
            {
                if ($PSBoundParameters.Keys -notcontains 'QueueExpirationPromptName')
                {
                    throw "When -QueueExpirationAction is set to ""PLAY_PROMPT"", a prompt name must be provided using -QueueExpirationPromptName."
                    return
                }

                $outboundCampaign.actionOnQueueExpiration.actionType = "PLAY_PROMPT"
                $outboundCampaign.actionOnQueueExpiration.actionArgument = $QueueExpirationPromptName
            }
            elseif ($QueueExpirationAction -eq 'START_IVR_SCRIPT')
            {
                if ($PSBoundParameters.Keys -notcontains 'QueueExpirationIVRScriptName')
                {
                    throw "When -QueueExpirationAction is set to ""START_IVR_SCRIPT"", an IVR script name must be provided using -QueueExpirationIVRScriptName."
                    return
                }

                $outboundCampaign.actionOnQueueExpiration.actionType = "START_IVR_SCRIPT"
                $outboundCampaign.actionOnQueueExpiration.actionArgument = $QueueExpirationIVRScriptName
            }

        }


        if ($PSBoundParameters.Keys -contains 'EnableListDialingRatios')
        {
            $outboundCampaign.enableListDialingRatios = $EnableListDialingRatios
            $outboundCampaign.enableListDialingRatiosSpecified = $true
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new outbound campaign '$Name'." 
        $response = $global:DefaultFive9AdminClient.createOutboundCampaign($outboundCampaign)


        return $response
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}


