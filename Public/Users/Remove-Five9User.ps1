<#
.SYNOPSIS
    
    Function used to delete a user
 
.DESCRIPTION
 
    Function used to delete a user
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client


.PARAMETER Username
 
    New skill name

   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9Skill -Five9AdminClient $adminClient -Username 'jdoe@domain.com'
    
    # Deletes user with username "jdoe@domain.com"
    

#>
function Remove-Five9Skill
{
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Username
    )

    $response = $Five9AdminClient.deleteUser($Username)

    return $response

}