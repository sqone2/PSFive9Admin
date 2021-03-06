function Set-Five9RoleSupervisor
{
    <#
    .SYNOPSIS
    
        Function used to modify a user's supervisor role

    .EXAMPLE
    
        Set-Five9UserSupervisorRole -Username 'jdoe@domain.com' -FullPermissions $true
    
        # Grants user 'jdoe@domain.com' all supervisor rights

    .EXAMPLE
    
        Set-Five9UserSupervisorRole -Username 'jdoe@domain.com' -Users $true -Agents $true -Campaigns $false
    
        # Modifies supervisor rights for user 'jdoe@domain.com'

    .LINK

        Add-Five9Role
        Remove-Five9Role
        Set-Five9RoleAdmin
        Set-Five9RoleAgent
        Set-Five9RoleReporting

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

        # If set to $true, user will be granted full supervisor permissions
        [Parameter(Mandatory=$false)][bool]$FullPermissions,

        [Parameter(Mandatory=$false)][bool]$Users,
        [Parameter(Mandatory=$false)][bool]$Agents,
        [Parameter(Mandatory=$false)][bool]$Stations,
        [Parameter(Mandatory=$false)][bool]$CanUseSupervisorSoapApi,
        [Parameter(Mandatory=$false)][bool]$ChatSessions,
        [Parameter(Mandatory=$false)][bool]$Campaigns,
        [Parameter(Mandatory=$false)][bool]$CanAccessDashboardMenu,
        [Parameter(Mandatory=$false)][bool]$CallMonitoring,
        [Parameter(Mandatory=$false)][bool]$CampaignManagement,
        [Parameter(Mandatory=$false)][bool]$CanRunJavaClient,
        [Parameter(Mandatory=$false)][bool]$CanRunWebClient,
        [Parameter(Mandatory=$false)][bool]$CanChangeDisplayLanguage,
        [Parameter(Mandatory=$false)][bool]$CanMonitorIdleAgents,
        [Parameter(Mandatory=$false)][bool]$AllSkills,
        [Parameter(Mandatory=$false)][bool]$BillingInfo,
        [Parameter(Mandatory=$false)][bool]$BargeInMonitor,
        [Parameter(Mandatory=$false)][bool]$WhisperMonitor,
        [Parameter(Mandatory=$false)][bool]$ViewDataForAllAgentGroups,
        [Parameter(Mandatory=$false)][bool]$ReviewVoiceRecordings,
        [Parameter(Mandatory=$false)][bool]$EditAgentSkills,
        [Parameter(Mandatory=$false)][bool]$CanAccessShowFields

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

        if ($objToModify.roles.supervisor -eq $null)
        {
            throw "Supervisor role has not yet been added. Please use Add-Five9Role to add Supervisor role, and then try again."
            return
        }


        if ($FullPermissions -eq $true)
        {
            $allPermissions = $objToModify.roles.supervisor.type | ? {$_ -ne 'NICEEnabled'}

            foreach ($permission in $allPermissions)
            {
                ($objToModify.roles.supervisor | ? {$_.type -eq $permission}).value = $true
                ($objToModify.roles.supervisor | ? {$_.type -eq $permission}).typeSpecified = $true
            }

            $roleToModify = New-Object PSFive9Admin.userRoles
            $roleToModify.supervisor = @($objToModify.roles.supervisor)


        }
        else
        {
            # get parameters passed that are part of the permissions array in the supervsior user role
            $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$objToModify.roles.supervisor.type -contains $_ })

            # if no parameters were passed that change the supervisor role, abort
            if ($permissionKeysPassed.Count -eq 0)
            {
                throw "No parameters were passed to modify supervisor role."
                return
            }


            # set values in permissions array based on parameters passed
            foreach ($key in $permissionKeysPassed)
            {
                ($objToModify.roles.supervisor | ? {$_.type -eq $key}).typeSpecified = $true
                ($objToModify.roles.supervisor | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]
            }

            $roleToModify = New-Object PSFive9Admin.userRoles
            $roleToModify.supervisor = @($objToModify.roles.supervisor)

        }

        if ($PsCmdLet.ParameterSetName -eq "Username")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Supervisor' role on user '$Username'." 
            $response = $global:DefaultFive9AdminClient.modifyUser($objToModify.generalInfo, $roleToModify, $null)
        }
        elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Supervisor' role on user profile '$UserProfileName'." 
            $response = $global:DefaultFive9AdminClient.modifyUserProfile($objToModify)
        }

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
