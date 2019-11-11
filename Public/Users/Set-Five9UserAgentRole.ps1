<#
.SYNOPSIS
    
    Function used to modify a user's agent role
 
.DESCRIPTION
 
    Function used to modify a user's agent role
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Username
 
    Username of user whose role is being modified


.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9UserAgentRole -Five9AdminClient $adminClient -Username 'jdoe@domain.com' -CanRunWebClient $true -AlwaysRecorded $true -SendMessages $false
    
    # Modifies agent role on user "jdoe@domain.com"
    

#>
function Set-Five9UserAgentRole
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    (

        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username,

        [Parameter(Mandatory=$false)][bool]$AlwaysRecorded,
        [Parameter(Mandatory=$false)][bool]$AttachVmToEmail,
        [Parameter(Mandatory=$false)][bool]$SendEmailOnVm,
        [Parameter(Mandatory=$false)][bool]$ReceiveTransfer,
        [Parameter(Mandatory=$false)][bool]$MakeRecordings,
        [Parameter(Mandatory=$false)][bool]$CanRunJavaClient,
        [Parameter(Mandatory=$false)][bool]$SendMessages,
        [Parameter(Mandatory=$false)][bool]$CanRunWebClient,
        [Parameter(Mandatory=$false)][bool]$CreateChatSessions,
        [Parameter(Mandatory=$false)][bool]$TrainingMode,
        [Parameter(Mandatory=$false)][bool]$CanSelectDisplayLanguage,
        [Parameter(Mandatory=$false)][bool]$CanViewMissedCalls,
        [Parameter(Mandatory=$false)][bool]$CanViewWebAnalytics,
        [Parameter(Mandatory=$false)][bool]$CanTransferChatsToAgents,
        [Parameter(Mandatory=$false)][bool]$CanTransferChatsToSkills,
        [Parameter(Mandatory=$false)][bool]$CanTransferEmailsToAgents,
        [Parameter(Mandatory=$false)][bool]$CanTransferEmailsToSkills,
        [Parameter(Mandatory=$false)][bool]$CannotRemoveCRM,
        [Parameter(Mandatory=$false)][bool]$CanCreateChatConferenceWithAgents,
        [Parameter(Mandatory=$false)][bool]$CanCreateChatConferenceWithSkills,
        [Parameter(Mandatory=$false)][bool]$CanTransferSocialsToAgents,
        [Parameter(Mandatory=$false)][bool]$CanTransferSocialsToSkills,
        [Parameter(Mandatory=$false)][bool]$ProcessVoiceMail,
        [Parameter(Mandatory=$false)][bool]$CallForwarding,
        [Parameter(Mandatory=$false)][bool]$CannotEditSession,
        [Parameter(Mandatory=$false)][bool]$TransferVoiceMail,
        [Parameter(Mandatory=$false)][bool]$DeleteVoiceMail,
        [Parameter(Mandatory=$false)][bool]$AddingToDNC,
        [Parameter(Mandatory=$false)][bool]$DialManuallyDNC,
        [Parameter(Mandatory=$false)][bool]$CreateCallbacks,
        [Parameter(Mandatory=$false)][bool]$PlayAudioFiles,
        [Parameter(Mandatory=$false)][bool]$CanWrapCall,
        [Parameter(Mandatory=$false)][bool]$CanPlaceCallOnHold,
        [Parameter(Mandatory=$false)][bool]$CanParkCall,
        [Parameter(Mandatory=$false)][bool]$SkipCrmInPreviewDialMode,
        [Parameter(Mandatory=$false)][bool]$ManageAvailabilityBySkill,
        [Parameter(Mandatory=$false)][bool]$BrowseWebInEmbeddedBrowser,
        [Parameter(Mandatory=$false)][bool]$ChangePreviewPreferences,
        [Parameter(Mandatory=$false)][bool]$CanRejectCalls,
        [Parameter(Mandatory=$false)][bool]$CanConfigureAutoAnswer,
        [Parameter(Mandatory=$false)][bool]$MakeTransferToAgents,
        [Parameter(Mandatory=$false)][bool]$MakeTransferToSkills,
        [Parameter(Mandatory=$false)][bool]$CreateConferenceWithAgents,
        [Parameter(Mandatory=$false)][bool]$CreateConferenceWithSkills,
        [Parameter(Mandatory=$false)][bool]$RecycleDispositionAllowed,
        [Parameter(Mandatory=$false)][bool]$MakeTransferToInboundCampaigns,
        [Parameter(Mandatory=$false)][bool]$MakeTransferToExternalCalls,
        [Parameter(Mandatory=$false)][bool]$CreateConferenceWithInboundCampaigns,
        [Parameter(Mandatory=$false)][bool]$CreateConferenceWithExternalCalls,
        [Parameter(Mandatory=$false)][bool]$MakeCallToSkills,
        [Parameter(Mandatory=$false)][bool]$MakeCallToAgents,
        [Parameter(Mandatory=$false)][bool]$MakeCallToExternalCalls,
        [Parameter(Mandatory=$false)][bool]$MakeCallToSpeedDialNumber,
        [Parameter(Mandatory=$false)][bool]$MakeTransferToSpeedDialNumber,
        [Parameter(Mandatory=$false)][bool]$CreateConferenceWithSpeedDialNumber,
        [Parameter(Mandatory=$false)][bool]$ScreenRecording
    )


    $userToModify = $null
    $userToModify = $Five9AdminClient.getUserInfo($Username)

    if ($userToModify.Count -gt 1)
    {
        throw "Multiple user matches were found using query: ""$Username"". Please try using the exact username of the user you're trying to modify."
        return
    }

    if ($userToModify -eq $null)
    {
        throw "Cannot find a Five9 user with username: ""$Username"". Remember that username is case sensitive."
        return
    }

    if ($userToModify.roles.agent -eq $null)
    {
        throw "Agent role has not yet been added. Please use Add-Five9UserRole to add Agent role, and then try again."
        return
    }

    # get all parameters passed which modify agent role
    $keysPassed = @($PSBoundParameters.Keys | ? {$_ -notmatch 'Five9AdminClient|Username'})

    # if no parameters were passed that change the agent, end function
    if ($keysPassed.Count -eq 0)
    {
        throw "No parameters were passed to modify agent role."
        return
    }


    # set "root" values on agent role
    if ($PSBoundParameters.Keys -contains "AlwaysRecorded")
    {
        $userToModify.roles.agent.alwaysRecorded = $AlwaysRecorded
    }

    if ($PSBoundParameters.Keys -contains "AttachVmToEmail")
    {
        $userToModify.roles.agent.attachVmToEmail = $AttachVmToEmail
    }

    if ($PSBoundParameters.Keys -contains "SendEmailOnVm")
    {
        $userToModify.roles.agent.sendEmailOnVm = $SendEmailOnVm
    }


    # get parameters passed that are part of the permissions array in the agent user role
    $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$userToModify.roles.agent.permissions.type -contains $_ })


    # set values in permissions array based on parameters passed
    foreach ($key in $permissionKeysPassed)
    {
        ($userToModify.roles.agent.permissions | ? {$_.type -eq $key}).typeSpecified = $true
        ($userToModify.roles.agent.permissions | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]
    }

    $roleToModify = New-Object PSFive9Admin.userRoles
    $roleToModify.agent = $userToModify.roles.agent


    $response = $Five9AdminClient.modifyUser($userToModify.generalInfo, $roleToModify, $null)

    return $response.roles



}


