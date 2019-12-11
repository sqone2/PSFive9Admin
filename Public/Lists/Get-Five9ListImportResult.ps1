<#
.SYNOPSIS
    
    Function used to get the detailed outcome of using the Add-Five9ListRecord cmdlet
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Identifier

    String returned from Add-Five9ContactRecord. See example.

.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    $importId = Add-Five9ListRecord -Five9AdminClient $adminClient -CsvPath 'c:\files\contacts.csv'

    #
    #    Add-Five9ListRecord will return:
    #
    #    identifier                          
    #    ----------                          
    #    4833baab-9ded-4ade-b131-5263b269bdb9
    #

    Get-Five9ListImportResult -Five9AdminClient $adminClient -Identifier $importId

    # Returns the result of the contact records import process




#>
function Get-Five9ListImportResult
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][guid]$Identifier
    )

    $importIdentifier = New-Object PSFive9Admin.importIdentifier

    # check to see if importIdentifier object was passed, or string
    if ($($Identifier.GetType().Name) -eq 'importIdentifier')
    {
        $importIdentifier.identifier = $Identifier.identifier
    }
    else
    {
        $importIdentifier.identifier = $Identifier
    }

    return $Five9AdminClient.getListImportResult($importIdentifier)

}
