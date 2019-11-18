<#
.SYNOPSIS
    
    Function used to delete a Five9 disposition
 
.DESCRIPTION
 
    Function used to delete a Five9 disposition
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Name

    Name of existing disposition to be removed

   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9Disposition -Five9AdminClient $adminClient -Name "Default-Disposition"

    # Deletes existing disposition named "Default-Disposition"

    
 
#>
function Remove-Five9Disposition
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name
    )


    $response = $Five9AdminClient.removeDisposition($Name)

    return $response

}

