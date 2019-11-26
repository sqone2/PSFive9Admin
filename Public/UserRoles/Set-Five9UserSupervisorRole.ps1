<#
.SYNOPSIS
    
    Function used to modify a user's supervisor role
 
.DESCRIPTION
 
    Function used to modify a user's supervisor role
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Username
 
    Username of user whose role is being modified

.PARAMETER FullPermissions
 
    If set to $true, user will be granted full supervisor permissions 


.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9UserSupervisorRole -Five9AdminClient $adminClient -Username 'jdoe@domain.com' -FullPermissions $true
    
    # Grants user 'jdoe@domain.com' all supervisor rights

.EXAMPLE
    
    Set-Five9UserSupervisorRole -Five9AdminClient $adminClient -Username 'jdoe@domain.com' -Users $true -Agents $true -Campaigns $false
    
    # Modifies supervisor rights for user 'jdoe@domain.com'
    

#>
function Set-Five9UserSupervisorRole
{
    [CmdletBinding(DefaultParametersetName='Granular',PositionalBinding=$false)]
    param
    (

        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username,

        [Parameter(ParameterSetName='FullPermissions',Mandatory=$true)][string]$FullPermissions,

        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CampaignManagementStart,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CampaignManagementStop,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CampaignManagementReset,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CampaignManagementResetDispositions,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CampaignManagementResetListPositions,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CampaignManagementResetAbandonCallRate,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewTextDetailsTab,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$Users,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$Agents,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$Stations,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ChatSessions,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$Campaigns,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanAccessDashboardMenu,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CallMonitoring,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CampaignManagement,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$AllowedRunJavaClient,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$AllowedRunWebClient,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanChangeDisplayLanguage,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanMonitorIdleAgents,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$AllSkills,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$BillingInfo,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$BargeInMonitor,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$WhisperMonitor,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ViewDataForAllAgentGroups,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ReviewVoiceRecordings,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditAgentSkills,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanAccessShowFields

    )

    $userToModify = $null
    try
    {
        $userToModify = $Five9AdminClient.getUserInfo($Username)
    }
    catch
    {
    
    }

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

    if ($userToModify.roles.supervisor -eq $null)
    {
        throw "Supervisor role has not yet been added. Please use Add-Five9UserRole to add Supervisor role, and then try again."
        return
    }


    if ($FullPermissions -eq $true)
    {
        $allPermissions = $userToModify.roles.supervisor.type

        foreach ($permission in $allPermissions)
        {
            ($userToModify.roles.supervisor | ? {$_.type -eq $permission}).value = $true
            ($userToModify.roles.supervisor | ? {$_.type -eq $permission}).typeSpecified = $true
        }

        $roleToModify = New-Object PSFive9Admin.userRoles
        $roleToModify.supervisor = @($userToModify.roles.supervisor)


    }
    else
    {
        # get parameters passed that are part of the permissions array in the supervsior user role
        $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$userToModify.roles.supervisor.type -contains $_ })

        # if no parameters were passed that change the supervisor role, abort
        if ($permissionKeysPassed.Count -eq 0)
        {
            throw "No parameters were passed to modify supervisor role."
            return
        }


        # set values in permissions array based on parameters passed
        foreach ($key in $permissionKeysPassed)
        {
            ($userToModify.roles.supervisor | ? {$_.type -eq $key}).typeSpecified = $true
            ($userToModify.roles.supervisor | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]
        }

        $roleToModify = New-Object PSFive9Admin.userRoles
        $roleToModify.supervisor = @($userToModify.roles.supervisor)


    }

    $response = $Five9AdminClient.modifyUser($userToModify.generalInfo, $roleToModify, $null)

    return $response.roles

}
