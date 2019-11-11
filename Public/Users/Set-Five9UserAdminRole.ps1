<#
.SYNOPSIS
    
    Function used to modify a user's admin role
 
.DESCRIPTION
 
    Function used to modify a user's admin role
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Username
 
    Username of user whose role is being modified

.PARAMETER FullPermissions
 
    If set to $true, user will be granted full admin permissions including the ability to edit other administrators


.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9UserAdminRole -Five9AdminClient $adminClient -Username 'jdoe@domain.com' -FullPermissions $true
    
    # Grants user 'jdoe@domain.com' full admin rights

.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9UserAdminRole -Five9AdminClient $adminClient -Username 'jdoe@domain.com' -ManageSkills $false -EditConnectors $false -AccessConfigANI $true
    
    # Modifies admin rights for user 'jdoe@domain.com'
    

#>
function Set-Five9UserAdminRole
{
    [CmdletBinding(DefaultParametersetName='Granular',PositionalBinding=$false)]
    param
    (

        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username,

        [Parameter(ParameterSetName='FullPermissions',Mandatory=$true)][string]$FullPermissions,

        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditIvr,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditWorkflowRules,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditTrustedIPAddresses,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditReasonCodes,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageCampaignsReset,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditPrompts,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageLists,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageCampaignsStartStop,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageSkills,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditDispositions,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageCampaignsResetListPosition,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditProfiles,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditDomainEMailNotification,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageDNC,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditConnectors,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditCallAttachedData,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$EditCampaignEMailNotification,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$AccessConfigANI,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageCampaignsProperties,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageCampaignsResetDispositions,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageUsers,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageCRM,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$ManageAgentGroups
        #[Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$AccessBillingApplication, # field cannot be set
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

    if ($userToModify.roles.admin -eq $null)
    {
        throw "Admin role has not yet been added. Please use Add-Five9UserRole to add Admin role, and then try again."
        return
    }

    if ($FullPermissions -eq $true)
    {
        $adminPermission = New-Object PSFive9Admin.adminPermission
        $adminPermission.type = 'FullPermissions'
        $adminPermission.typeSpecified = $true
        $adminPermission.value = $true

        $roleToModify = New-Object PSFive9Admin.userRoles
        $userToModify.admin = @($adminPermission)


    }
    else
    {
        # get parameters passed that are part of the permissions array in the admin user role
        $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$userToModify.roles.admin.type -contains $_ })

        # if no parameters were passed that change the admin, end function
        if ($permissionKeysPassed.Count -eq 0)
        {
            throw "No parameters were passed to modify admin role."
            return
        }


        # set values in permissions array based on parameters passed
        foreach ($key in $permissionKeysPassed)
        {
            ($userToModify.roles.admin | ? {$_.type -eq $key}).typeSpecified = $true
            ($userToModify.roles.admin | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]
        }


        $roleToModify = New-Object PSFive9Admin.userRoles
        $roleToModify.admin = $userToModify.roles.admin | ? {$_.type -ne "AccessBillingApplication"}

    }

    $response = $Five9AdminClient.modifyUser($userToModify.generalInfo, $roleToModify, $null)

    return $response.roles

}
