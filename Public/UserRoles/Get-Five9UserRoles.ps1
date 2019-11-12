<#
.SYNOPSIS
    
    Function used to get a user's roles
 
.DESCRIPTION
 
    Function used to get a user's roles
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client


.PARAMETER Username
 
    Username whose roles will be returned
   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9UserRoles -Five9AdminClient $adminClient -Username "jdoe@domain.com"
    
    # Returns roles for user "jdoe@domain.com"
    


 
#>

function Get-Five9UserRoles
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$false)][string]$Username
    )

    $five9User = $null
    try
    {
        
        $five9User = $Five9AdminClient.getUserInfo($Username)
    }
    catch
    {

    }

    if ($five9User.Count -gt 1)
    {
        throw "Multiple user matches were found using query: ""$Username"". Please try using the exact username of the user you're trying to get."
        return
    }

    if ($five9User -eq $null)
    {
        throw "Cannot find a Five9 user with username: ""$Username"". Remember that username is case sensitive."
        return
    }

    
    return $five9User.roles

}



