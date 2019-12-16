<#
.SYNOPSIS
    
    Function used to create a new outbound campaign in Five9
 
.PARAMETER Name

	Name of new campaign. Only mandatory parameter

.PARAMETER Description

	Description of new campaign

.PARAMETER MaxQueueTimeMinutes

	Maximum time allowed for calls in a queue (minutes)

.PARAMETER MaxQueueTimeSeconds = 1

	Maximum time allowed for calls in a queue (seconds)

.PARAMETER UseTelemarketingMaxQueTime

	Sets the max queue time to 1 second

.PARAMETER DialingMode

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

.PARAMETER ShowOutOfNumbersAlert

    When an outbound campaign runs out of numbers to dial, whether to turn off notification messages to administrators and supervisors that the campaign is no longer dialing because the lists are complete

.PARAMETER UseDnisAsAn

    When transferring calls to third parties, whether to override the default DNIS of the domain by using the contact’s phone number (ANI) as the DNIS (caller ID)
    Options are:
        • True: Override the default DNIS
        • False: Do not override the default DNIS

.PARAMETER TrainingMode

	Whether the campaign is in training mode

.PARAMETER Mode

    Mode of new campaign. If not specified default set to BASIC.
    Options are:
        • BASIC (Default) -  Campaign with default settings without a campaign profile
        • ADVANCED - Campaign with a campaign profile specified in the profileName parameter

.PARAMETER ProfileName

    Campaign profile name. Applies only to the advanced campaign mode

.PARAMETER DistributionAlgorithm

    Method used by the ACD to transfer calls to agents
    Options are:
        • LongestReadyTime
        • LongestReadyTimeExcludeMC
        • RoundRobin
        • MinCallsHandled
        • MinHandleTime

.PARAMETER DistributionTimeFrame

    Time intervals used by DistributionAlgorithm. Only used when DistributionAlgorithm is set to MinCallsHandled or MinHandleTime 
    Default is minutes15


.PARAMETER CallWrapupEnabled

    Enables the "After Call Work Time Limit" setting on the campaign

.PARAMETER WrapupAgentNotReady

    Whether to automatically place agents who reach a call timeout in a Not Ready state
    Options are:
        • True: Set agents to Not Ready state
        • False: Do not set agents to Not Ready state

.PARAMETER WrapupDispostionName

    Name of disposition automatically set for the call if the timeout is reached
    Note: Disposition must FIRST be added to campaign's list of dispositions using the GUI or "Add-Five9CampaignDisposition"

.PARAMETER WrapupReasonCodeName
    
    Not Ready reason code for agents who are automatically placed in Not Ready state after reaching the timeout
    Note: Reason codes must first be enabled globally: Actions > Configure > Other > Enable Reason Codes

.PARAMETER WrapupTimerDays

    Number of Days used on wrap up timer

.PARAMETER WrapupTimerHours

    Number of Hours used on wrap up timer

.PARAMETER WrapupTimerMinutes

    Number of Minutes used on wrap up timer

.PARAMETER WrapupTimerSeconds
    
    Number of Seconds used on wrap up timer

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

.PARAMETER DurationBeforeRedialHours = 8

    Minimum time before redialing a contact record after all numbers for the contact record have been dialed or skipped (hours)

.PARAMETER DurationBeforeRedialMinutes = 0

    Minimum time before redialing a contact record after all numbers for the contact record have been dialed or skipped (minutes)

.PARAMETER CallsAgentRatio

    For campaigns in the predictive mode, number of phone numbers dialed for an agent ready for a new call

.PARAMETER PreviewMode

    Mode for whether agents are allowed to preview calls before their dialed
    Options are: 
        • Unlimited_Preview_Time
            Allow agents to preview the contact number for an unlimited time
        • Limited_Preview_Time
            Dial contact number after maxPreviewTime is reached
        • No_Preview_Time
            Automatically dial the number without waiting for an action from the agent

.PARAMETER MaxPreviewTimeMinutes

    Duration until expiration of the preview time
    Only used when PreviewMode is Limited_Preview_Time

.PARAMETER MaxPreviewTimeSeconds
    Duration until expiration of the preview time
    Only used when PreviewMode is Limited_Preview_Time

.PARAMETER MaxPreviewTimeAction

    Duration until expiration of the preview time
    Only used when PreviewMode is Limited_Preview_Time

.PARAMETER ListDialingMode

    Sets list dialing mode
    Options are:
        • VERTICAL_DIALING
            Dialer attempts to call all numbers in a CRM record before proceeding to the next record.
        • LIST_PENETRATION
            Dialer attempts to call all numbers in a column before proceeding to the next column
        • EXTENDED_STRATEGY
            Dialer attempts to call numbers in a list in order of importance. For example, until a contact is reached, numbers that are more important are redialed sooner and more often than those that are not

.PARAMETER MonitorDroppedCalls

    Whether to keep track of the dropped call percentage of the campaign

.PARAMETER MaxDroppedCallsPercentage

    Only used when MonitorDroppedCalls is True

.PARAMETER CallAnalysisMode

    Sets type of call analysis that will take place when a call is answered
    Options are:
        • NO_ANALYSIS
            No detection is attempted
        • FAX_ONLY
            Fax detection is attempted
        • FAX_AND_ANSWERING_MACHINE
            Fax and answering machine detection are attempted

.PARAMETER VoiceDetectionLevel = 2.0 #  // 20 = 2sec 100 = 10sec

    Voice detection level for an answering machine. For example: if set to 3.5, voice detection will take 3.5 seconds to try and determine whether a real person or an answering machine has answered the call. During this time, the remote party will hear dead air.
    Only used when CallAnalysisMode is FAX_AND_ANSWERING_MACHINE

.PARAMETER AnswerMachineAction

    Action to take when the answering machine is detected.
    Options are:
        • DROP_CALL
            Call is dropped
        • PLAY_PROMPT
            Prompt is played as specified by -AnswerMachinePromptName
        • START_IVR_SCRIPT
            IVR script started as specified by -AnswerMachineIVRScriptName

.PARAMETER AnswerMachineIVRScriptName

    Name of IVR script to be started when answering machine is detected
    Only used when ActionOnAnswerMachine is START_IVR_SCRIPT

.PARAMETER AnswerMachinePromptName

    Name of prompt to be played when answering machine is detected
    Only used when ActionOnAnswerMachine is PLAY_PROMPT

.PARAMETER AnswerMachineMaxWaitSeconds
    
    Number of seconds to be waited before prompt is played after answering machine is detected
    Only used when ActionOnAnswerMachine is PLAY_PROMPT

.PARAMETER QueueExpirationAction

    Action to take when the maximum queue time expires, which occurs when no agent is available to take a call
    Options are:
        • DROP_CALL
            Call is dropped
        • PLAY_PROMPT
            Prompt is played as specified by -QueueExpirationPromptName
        • START_IVR_SCRIPT
            IVR script started as specified by -QueueExpirationIVRScriptName

.PARAMETER QueueExpirationIVRScriptName 

    Name of IVR script to be started when max queue time expires
    Only used when QueueExpirationAction is START_IVR_SCRIPT

.PARAMETER QueueExpirationPromptName 

    Name of prompt to be played when max queue time expires
    Only used when QueueExpirationAction is PLAY_PROMPT

.PARAMETER EnableListDialingRatios

    Whether to use list dialing ratios, which enable multiple lists to be dialed at specified frequencies


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9OutboundCampaign -Five9AdminClient $adminClient -Name "Hot-Leads"

    #Creates a new outbound campaign using all default values

.EXAMPLE
    Set-Five9OutboundCampaign -Five9AdminClient $adminClient -Name "Hot-Leads" -DialingMode: PREVIEW -PreviewMode: Limited_Preview_Time -MaxPreviewTimeAction: Dial_Number -MaxPreviewTimeMinutes 1 -MaxPreviewTimeSeconds 30

    #Creates a new outbound campaign using in preview mode where calls are made after previewing for 1 minute and 30 seconds

.EXAMPLE
    Set-Five9OutboundCampaign -Five9AdminClient $adminClient -Name "Hot-Leads" -UseTelemarketingMaxQueTime $true -DialingMode: POWER -CallsAgentRatio 2 -QueueExpirationAction: DROP_CALL

    #Creates a new outbound campaign in "Power" using a 2:1 agent ratio

.EXAMPLE

    Set-Five9OutboundCampaign -Five9AdminClient $adminClient -Name "Hot-Leads" -UseTelemarketingMaxQueTime $true -DialingMode: PROGRESSIVE `
                              -CallsAgentRatio 5 -CallAnalysisMode: FAX_AND_ANSWERING_MACHINE -VoiceDetectionLevel 3.5 `
                              -AnswerMachineAction: START_IVR_SCRIPT -AnswerMachineIVRScriptName "Answer-Machine-IVR" `
                              -QueueExpirationAction: START_IVR_SCRIPT -QueueExpirationIVRScriptName "Abandon-Call-IVR"

    #Creates a new outbound campaign in "Progressive" using a 5:1 agent ratio. Also enables answering machine detection 
#>
function Set-Five9OutboundCampaign
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,


        # General Tab
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$NewName,
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
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxPreviewTimeMinutes = 2, # only used when PreviewMode is Limited_Preview_Time
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$MaxPreviewTimeSeconds = 0, # only used when PreviewMode is Limited_Preview_Time
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
        [Parameter(Mandatory=$false)][ValidateRange(0,60.0)][int]$AnswerMachineMaxWaitSeconds = 20, #only used when ActionOnAnswerMachine is PLAY_PROMPT

        [Parameter(Mandatory=$false)][ValidateSet('DROP_CALL', 'PLAY_PROMPT', 'START_IVR_SCRIPT')][string]$QueueExpirationAction,
        [Parameter(Mandatory=$false)][string]$QueueExpirationIVRScriptName, #only used when QueueExpirationAction is START_IVR_SCRIPT
        [Parameter(Mandatory=$false)][string]$QueueExpirationPromptName, #only used when QueueExpirationAction is PLAY_PROMPT

        # Lists
        [Parameter(Mandatory=$false)][bool]$EnableListDialingRatios

    )

    $existingCampaign = $null
    try
    {
        $existingCampaign = $Five9AdminClient.getOutboundCampaign($Name)
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


    $campaignToModify = New-Object PSFive9Admin.outboundCampaign
    $campaignToModify.name = $existingCampaign.name


    $campaignToModify.name = $Name


    $campaignToModify.maxQueueTime = New-Object PSFive9Admin.timer
    if ($UseTelemarketingMaxQueTime -eq $true)
    {
        $campaignToModify.maxQueueTime.seconds = 1
        $campaignToModify.useTelemarketingMaxQueTimeEq1 = $true
        $campaignToModify.useTelemarketingMaxQueTimeEq1Specified = $true

    }
    else
    {
        $campaignToModify.maxQueueTime.minutes = $MaxQueueTimeMinutes
        $campaignToModify.maxQueueTime.seconds = $MaxQueueTimeSeconds
    }



    if ($PSBoundParameters.Keys -contains 'DialingMode')
    {
        $campaignToModify.dialingMode = $DialingMode
        $campaignToModify.dialingModeSpecified = $true
    }
    
    if ($PSBoundParameters.Keys -contains 'Description')
    {
        $campaignToModify.description = $Description
    }

    if ($PSBoundParameters.Keys -contains 'ShowOutOfNumbersAlert')
    {
        $campaignToModify.noOutOfNumbersAlert = $ShowOutOfNumbersAlert
        $campaignToModify.noOutOfNumbersAlertSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'UseDnisAsAni')
    {
        $campaignToModify.dnisAsAni = $UseDnisAsAni
        $campaignToModify.dnisAsAniSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'TrainingMode')
    {
        $campaignToModify.trainingMode = $TrainingMode
        $campaignToModify.trainingModeSpecified = $true
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


    if ($PSBoundParameters.Keys -contains 'DistributionAlgorithm')
    {
        $campaignToModify.distributionAlgorithm = $DistributionAlgorithm
        $campaignToModify.distributionAlgorithmSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'DistributionTimeFrame')
    {
        $campaignToModify.distributionTimeFrame = $DistributionTimeFrame
        $campaignToModify.distributionTimeFrameSpecified = $true
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

    if ($PSBoundParameters.Keys -contains 'WrapupDispostionName')
    {
        $campaignToModify.callWrapup.dispostionName = $WrapupDispostionName
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


    if ($PSBoundParameters.Keys -contains 'CallsAgentRatio')
    {
        $campaignToModify.callsAgentRatio = $CallsAgentRatio
        $campaignToModify.callsAgentRatioSpecified = $true
    }


    $campaignToModify.CRMRedialTimeout = $existingCampaign.CRMRedialTimeout

    if ($PSBoundParameters.Keys -contains 'DurationBeforeRedialHours')
    {
        $campaignToModify.CRMRedialTimeout.hours = $DurationBeforeRedialHours
    }

    if ($PSBoundParameters.Keys -contains 'DurationBeforeRedialMinutes')
    {
        $campaignToModify.CRMRedialTimeout.minutes = $DurationBeforeRedialMinutes
    }

    if ($PSBoundParameters.Keys -contains 'PreviewMode')
    {
        if ($PreviewMode -eq 'No_Preview_Time')
        {
            $campaignToModify.previewDialImmediately = $true
            $campaignToModify.previewDialImmediatelySpecified = $true
        }
        elseif ($PreviewMode -eq 'Unlimited_Preview_Time')
        {
            $campaignToModify.limitPreviewTime = $false
            $campaignToModify.limitPreviewTimeSpecified = $true
        }
        elseif ($PreviewMode -eq 'Limited_Preview_Time')
        {
            $campaignToModify.limitPreviewTime = $true
            $campaignToModify.limitPreviewTimeSpecified = $true

            $campaignToModify.maxPreviewTime = New-Object PSFive9Admin.timer
            $campaignToModify.maxPreviewTime.minutes = $MaxPreviewTimeMinutes
            $campaignToModify.maxPreviewTime.seconds = $MaxPreviewTimeSeconds

            if ($MaxPreviewTimeAction -eq 'Dial_Number')
            {
                $campaignToModify.dialNumberOnTimeout = $true
                $campaignToModify.dialNumberOnTimeoutSpecified = $true
            }
            elseif ($MaxPreviewTimeAction -eq 'Set_Agent_Not_Ready')
            {
                $campaignToModify.dialNumberOnTimeout = $false
                $campaignToModify.dialNumberOnTimeoutSpecified = $true
            }
        }

    }



    if ($PSBoundParameters.Keys -contains 'ListDialingMode')
    {
        $campaignToModify.listDialingMode = $ListDialingMode
        $campaignToModify.listDialingModeSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'MonitorDroppedCalls')
    {
        $campaignToModify.monitorDroppedCalls = $MonitorDroppedCalls
        $campaignToModify.monitorDroppedCallsSpecified = $true
    }
    

    if ($PSBoundParameters.Keys -contains 'MaxDroppedCallsPercentage')
    {
        $campaignToModify.maxDroppedCallsPercentage = $MaxDroppedCallsPercentage
        $campaignToModify.maxDroppedCallsPercentageSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'CallAnalysisMode')
    {
        $campaignToModify.callAnalysisMode = $CallAnalysisMode
        $campaignToModify.callAnalysisModeSpecified = $true

        if ($CallAnalysisMode -eq 'FAX_AND_ANSWERING_MACHINE')
        {
            # the api wants a number between 20 and 100.
            # 20 = 2sec / 100 = 10sec. 
            # we'll multipy a smaller number by 10 to make this less confusing,. i.e. 3.5 * 10 = 35
            $campaignToModify.analyzeLevel = ($VoiceDetectionLevel * 10)
            $campaignToModify.analyzeLevelSpecified = $true
        }
    }




    $campaignToModify.actionOnAnswerMachine = $existingCampaign.actionOnAnswerMachine
    $campaignToModify.actionOnQueueExpiration = $existingCampaign.actionOnQueueExpiration


    if ($PSBoundParameters.Keys -contains 'AnswerMachineAction')
    {
     
        if ($AnswerMachineAction -eq 'PLAY_PROMPT' -and $PSBoundParameters.Keys -notcontains 'AnswerMachinePromptName')
        {
            throw "When -AnswerMachineAction is set to ""PLAY_PROMPT"", a prompt name must be provided using -AnswerMachinePromptName."
            return
        }
        elseif ($AnswerMachineAction -eq 'START_IVR_SCRIPT' -and $PSBoundParameters.Keys -notcontains 'AnswerMachineIVRScriptName')
        {
            throw "When -AnswerMachineAction is set to ""START_IVR_SCRIPT"", an IVR script name must be provided using -AnswerMachineIVRScriptName."
            return
        }
        elseif ($AnswerMachineAction -eq 'DROP_CALL')
        {
            $campaignToModify.actionOnAnswerMachine.actionType = "DROP_CALL"
            $campaignToModify.actionOnAnswerMachine.actionTypeSpecified = $true
        }

    }


    if ($PSBoundParameters.Keys -contains 'AnswerMachinePromptName')
    {
        $campaignToModify.actionOnAnswerMachine.actionTypeSpecified = $true
        $campaignToModify.actionOnAnswerMachine.actionType = "PLAY_PROMPT"
        $campaignToModify.actionOnAnswerMachine.actionArgument = $AnswerMachinePromptName
        $campaignToModify.actionOnAnswerMachine.maxWaitTime = New-Object PSFive9Admin.timer
        $campaignToModify.actionOnAnswerMachine.maxWaitTime.seconds = $AnswerMachineMaxWaitSeconds
    }

    if ($PSBoundParameters.Keys -contains 'AnswerMachineIVRScriptName')
    {
        $campaignToModify.actionOnAnswerMachine.actionTypeSpecified = $true
        $campaignToModify.actionOnAnswerMachine.actionType = "START_IVR_SCRIPT"
        $campaignToModify.actionOnAnswerMachine.actionArgument = $AnswerMachineIVRScriptName
    }


    if ($PSBoundParameters.Keys -contains 'QueueExpirationAction')
    {
        if ($QueueExpirationAction -eq 'PLAY_PROMPT' -and $PSBoundParameters.Keys -notcontains 'QueueExpirationPromptName')
        {
            throw "When -QueueExpirationAction is set to ""PLAY_PROMPT"", a prompt name must be provided using -QueueExpirationPromptName."
            return
        }
        elseif ($QueueExpirationAction -eq 'START_IVR_SCRIPT' -and $PSBoundParameters.Keys -notcontains 'QueueExpirationIVRScriptName')
        {
            throw "When -QueueExpirationAction is set to ""START_IVR_SCRIPT"", an IVR script name must be provided using -QueueExpirationIVRScriptName."
            return
        }
        elseif ($AnswerMachineAction -eq 'DROP_CALL')
        {
            $campaignToModify.actionOnQueueExpiration.actionType = "DROP_CALL"
            $campaignToModify.actionOnQueueExpiration.actionTypeSpecified = $true
        }

    }


    if ($PSBoundParameters.Keys -contains 'QueueExpirationPromptName')
    {
        $campaignToModify.actionOnQueueExpiration.actionType = "PLAY_PROMPT"
        $campaignToModify.actionOnQueueExpiration.actionTypeSpecified = $true
        $campaignToModify.actionOnQueueExpiration.actionArgument = $QueueExpirationPromptName
    }

    if ($PSBoundParameters.Keys -contains 'QueueExpirationIVRScriptName')
    {
        $campaignToModify.actionOnQueueExpiration.actionType = "START_IVR_SCRIPT"
        $campaignToModify.actionOnQueueExpiration.actionTypeSpecified = $true
        $campaignToModify.actionOnQueueExpiration.actionArgument = $QueueExpirationIVRScriptName
    }


    # can't allow prompt to be null
    if ($campaignToModify.actionOnQueueExpiration.actionType -eq 'PLAY_PROMPT' -and $campaignToModify.actionOnQueueExpiration.actionArgument.Length -lt 1)
    {
        throw "Campaign being modified is set ""PLAY_PROMPT"" on QueueExpirationAction, but no prompt is set. Please try again including -QueueExpirationPromptName"
        return
    }


    if ($PSBoundParameters.Keys -contains 'EnableListDialingRatios')
    {
        $campaignToModify.enableListDialingRatios = $EnableListDialingRatios
        $campaignToModify.enableListDialingRatiosSpecified = $true
    }


    try
    {

        $response = $Five9AdminClient.modifyOutboundCampaign($campaignToModify)


        if ($PSBoundParameters.Keys -contains 'NewName')
        {
            try
            {
                $Five9AdminClient.renameCampaign($existingCampaign.name, $NewName)
            }
            catch
            {
                throw $_
                return
            }
        }


    }
    catch
    {
        throw $_
        return
    }

}


