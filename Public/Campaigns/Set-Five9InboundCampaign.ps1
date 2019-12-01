<#
.SYNOPSIS
    
    Function used to modify an existing inbound campaign in Five9
 
.PARAMETER Name

    Name of existing campaign

.PARAMETER NewName

    Optional. Will rename campaign to this new name

.PARAMETER Description

     Description of campaign


.PARAMETER Mode

    Mode that existing campaign will be set to. If not specified, default set to BASIC.
    Options are:
        • BASIC (Default) -  Campaign with default settings, without a campaign profile
        • ADVANCED - Campaign with a campaign profile specified in the profileName parameter


.PARAMETER IvrScriptName

    Name of IVR script


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



.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9InboundCampaign -Five9AdminClient $adminClient -Name "Cold-Calls" -NewName "Warm-Calls" -IvrScriptName "Warm-Calls-IVR"
    
    # Changes name of existing campaign and changes IVR script

.EXAMPLE
    
    Set-Five9InboundCampaign -Five9AdminClient $adminClient -Name "Warm-Calls" -AutoRecord $true -RecordingNameAsSid $true -UseFtp $true -FtpHost '192.168.1.50' -FtpUser 'admin' -FtpPassword 'P@ssword!'
    
    # Modified recording values on existing campaign


 
#>
function Set-Five9InboundCampaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Name,

        [Parameter(Mandatory=$false)][string]$NewName,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][ValidateSet('BASIC', 'ADVANCED')][string]$Mode = 'BASIC',
        [Parameter(Mandatory=$false)][string]$ProfileName,
        [Parameter(Mandatory=$false)][string]$IvrScriptName,
        [Parameter(Mandatory=$false)][int]$MaxNumOfLines,

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

    $existingCampaign = $null
    try
    {
        $existingCampaign = $Five9AdminClient.getInboundCampaign($Name)
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

    if ($PSBoundParameters.Keys -contains 'MaxNumOfLines')
    {
        $campaignToModify.MaxNumOfLines = $MaxNumOfLines
        $campaignToModify.maxNumOfLinesSpecified = $true
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




    try
    {

        $response = $Five9AdminClient.modifyInboundCampaign($campaignToModify)


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

