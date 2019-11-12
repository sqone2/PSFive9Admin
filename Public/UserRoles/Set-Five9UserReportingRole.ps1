<#
.SYNOPSIS
    
    Function used to modify a user's reporting role
 
.DESCRIPTION
 
    Function used to modify a user's reporting role
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Username
 
    Username of user whose role is being modified

.PARAMETER FullPermissions
 
    If set to $true, user will be granted full reporting permissions 


.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9UserReportingRole -Five9AdminClient $adminClient -Username 'jdoe@domain.com' -FullPermissions $true
    
    # Grants user 'jdoe@domain.com' all reporting rights

.EXAMPLE
    
    Set-Five9UserReportingRole -Five9AdminClient $aacFive9AdminClient -Username 'jdoe@domain.com' -CanViewSocialReports $false -CanViewCannedReports $true
    
    # Modifies reporting rights for user 'jdoe@domain.com'
    

#>
function Set-Five9UserReportingRole
{
    [CmdletBinding(DefaultParametersetName='Granular',PositionalBinding=$false)]
    param
    (

        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username,

        [Parameter(ParameterSetName='FullPermissions',Mandatory=$true)][string]$FullPermissions,

        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewDashboards,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewAllSkills,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewAllGroups,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanAccessRecordingsColumn,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanScheduleReportsViaFtp,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewStandardReports,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewSocialReports,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewCustomReports,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewScheduledReports,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewRecentReports,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewRelease7Reports,
        [Parameter(ParameterSetName='Granular',Mandatory=$false)][bool]$CanViewCannedReports

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

    if ($userToModify.roles.reporting -eq $null)
    {
        throw "Reporting role has not yet been added. Please use Add-Five9UserRole to add reporting role, and then try again."
        return
    }


    if ($FullPermissions -eq $true)
    {
        $allPermissions = $userToModify.roles.reporting.type

        foreach ($permission in $allPermissions)
        {
            ($userToModify.roles.reporting | ? {$_.type -eq $permission}).value = $true
            ($userToModify.roles.reporting | ? {$_.type -eq $permission}).typeSpecified = $true
        }

        $roleToModify = New-Object PSFive9Admin.userRoles
        $roleToModify.reporting = @($userToModify.roles.reporting)


    }
    else
    {
        # get parameters passed that are part of the permissions array in the supervsior user role
        $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$userToModify.roles.reporting.type -contains $_ })

        # if no parameters were passed that change the reporting role, abort
        if ($permissionKeysPassed.Count -eq 0)
        {
            throw "No parameters were passed to modify reporting role."
            return
        }


        # set values in permissions array based on parameters passed
        foreach ($key in $permissionKeysPassed)
        {
            ($userToModify.roles.reporting | ? {$_.type -eq $key}).typeSpecified = $true
            ($userToModify.roles.reporting | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]
        }

        $roleToModify = New-Object PSFive9Admin.userRoles
        $roleToModify.reporting = @($userToModify.roles.reporting)


    }

    $response = $Five9AdminClient.modifyUser($userToModify.generalInfo, $roleToModify, $null)

    return $response.roles

}
