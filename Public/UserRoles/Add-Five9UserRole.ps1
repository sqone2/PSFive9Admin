<#
.SYNOPSIS
    
    Function used to add a new role to a user
 
.DESCRIPTION
 
    Function used to add a new role to a user
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Username
 
    Username of user role is being added to

.PARAMETER RoleName
 
    Name of role being added. Role permissions will be default. Use Set-Five9User<RoleName>Role to change permissions on role. i.e. Set-Five9UserAgentRole
   

.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Add-Five9UserRole -Five9AdminClient $adminClient -Username 'jdoe@domain.com' -RoleName Reporting
    
    # Adds default reporting role to user
    

#>
function Add-Five9UserRole
{

    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][ValidateSet("Agent", "Admin", "Supervisor", "Reporting")][string]$RoleName
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

    if ($userToModify.roles.$RoleName -ne $null)
    {
        throw "$RoleName has already been added to this user. Please use Set-Five9User$($RoleName)Role to modify role permisisons."
        return
    }


    $userRoles = New-Object -TypeName PSFive9Admin.userRoles

    if ($RoleName -eq "Agent")
    {
        $agentRole = New-Object -TypeName PSFive9Admin.agentRole
        $agentRole.permissions = @()

        $userRoles.agent = $agentRole

    }
    elseif ($RoleName -eq "Admin")
    {
        $userRoles.admin = @()
    }
    elseif ($RoleName -eq "Supervisor")
    {
        $userRoles.supervisor = @()
    }
    elseif ($RoleName -eq "Reporting")
    {
        $userRoles.reporting = @()
    }

    $response = $Five9AdminClient.modifyUser($userToModify.generalInfo, $userRoles, $null)

    return $response.roles

}

