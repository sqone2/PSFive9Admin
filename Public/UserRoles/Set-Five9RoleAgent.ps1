function Set-Five9RoleAgent
{
    <#
    .SYNOPSIS
    
        Function used to modify a user's agent role

    .EXAMPLE
    
        Set-Five9UserAgentRole -Username 'jdoe@domain.com' -CanRunWebClient $true -AlwaysRecorded $true -SendMessages $false
    
        # Modifies agent role on user "jdoe@domain.com"

    .LINK

        Add-Five9Role
        Remove-Five9Role
        Set-Five9RoleAdmin
        Set-Five9RoleReporting
        Set-Five9RoleSupervisor
    
    #>
    [CmdletBinding(DefaultParametersetName='Username',PositionalBinding=$false)]
    param
    (
        # Username of the user being modified
        # This parameter is not used when -UserProfileName is passed
        [Parameter(ParameterSetName='Username',Mandatory=$true,Position=0)][string]$Username,

        # Profile name being modified
        # This parameter is not used when -Username is passed
        [Parameter(ParameterSetName='UserProfileName',Mandatory=$true)][string]$UserProfileName,

        # If set to $true, user will be granted all agent permissions
        [Parameter(Mandatory=$false)][bool]$FullPermissions,

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
        #[Parameter(Mandatory=$false)][bool]$CanSelectDisplayLanguage,
        [Parameter(Mandatory=$false)][bool]$CanViewMissedCalls,
        #[Parameter(Mandatory=$false)][bool]$CanViewWebAnalytics,
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
        [Parameter(Mandatory=$false)][bool]$CreateConferenceWithSpeedDialNumber
        #[Parameter(Mandatory=$false)][bool]$ScreenRecording
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $objToModify = $null
        try
        {
            if ($PsCmdLet.ParameterSetName -eq "Username")
            {
                $objToModify = $global:DefaultFive9AdminClient.getUsersInfo($Username)
            }
            elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
            {
                $objToModify = $global:DefaultFive9AdminClient.getUserProfile($UserProfileName)
            }
            else
            {
                throw "Error setting media type. ParameterSetName not set."
            }

        }
        catch
        {

        }


        if ($objToModify.Count -gt 1)
        {
            throw "Multiple matches were found using query: ""$($Username)$($UserProfileName)"". Please try using the exact name of the user or profile you're trying to modify."
            return
        }

        if ($objToModify -eq $null)
        {
            throw "Cannot find a Five9 user or profile with name: ""$($Username)$($UserProfileName)"". Remember that this value is case sensitive."
            return
        }


        $objToModify = $objToModify | Select-Object -First 1

        if ($objToModify.roles.agent -eq $null)
        {
            throw "Agent role has not yet been added. Please use Add-Five9Role to add Agent role, and then try again."
            return
        }

        # set "root" values on agent role
        if ($PSBoundParameters.Keys -contains "AlwaysRecorded")
        {
            $objToModify.roles.agent.alwaysRecorded = $AlwaysRecorded
        }

        if ($PSBoundParameters.Keys -contains "AttachVmToEmail")
        {
            $objToModify.roles.agent.attachVmToEmail = $AttachVmToEmail
        }

        if ($PSBoundParameters.Keys -contains "SendEmailOnVm")
        {
            $objToModify.roles.agent.sendEmailOnVm = $SendEmailOnVm
        }


        if ($FullPermissions -eq $true)
        {
            # get all permissions except some that arent set in the GUI, not sure why this is. 
            $agentPermissions = $objToModify.roles.agent.permissions.type | ? {$_ -notmatch 'NICEEnabled|ScreenRecording|CanSelectDisplayLanguage|CanViewWebAnalytics'}

            foreach ($permission in $agentPermissions)
            {
                ($objToModify.roles.agent.permissions | ? {$_.type -eq $permission}).typeSpecified = $true
                ($objToModify.roles.agent.permissions | ? {$_.type -eq $permission}).value = $true
            }

        }
        else
        {
            # get all parameters passed which modify agent role
            $keysPassed = @($PSBoundParameters.Keys | ? {$_ -notmatch 'Username|FullPermissions'})

            # if no parameters were passed that change the agent, end function
            if ($keysPassed.Count -eq 0)
            {
                throw "No parameters were passed to modify agent role."
                return
            }

            # get parameters passed that are part of the permissions array in the agent user role
            $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$_ -notmatch 'FullPermissions' -and $objToModify.roles.agent.permissions.type -contains $_ })


            # set values in permissions array based on parameters passed
            foreach ($key in $permissionKeysPassed)
            {

                ($objToModify.roles.agent.permissions | ? {$_.type -eq $key}).typeSpecified = $true
                ($objToModify.roles.agent.permissions | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]

            }
        }



        $roleToModify = New-Object PSFive9Admin.userRoles
        $roleToModify.agent = $objToModify.roles.agent

        if ($PsCmdLet.ParameterSetName -eq "Username")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Agent' role on user '$Username'." 
            $response = $global:DefaultFive9AdminClient.modifyUser($objToModify.generalInfo, $roleToModify, $null)
        }
        elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
        {
            #$objToModify.roles.agent = $roleToModify.agent
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Agent' role on user profile '$UserProfileName'." 
            $response = $global:DefaultFive9AdminClient.modifyUserProfile($objToModify)
        }

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}


