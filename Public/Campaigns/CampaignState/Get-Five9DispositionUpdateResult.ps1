function Get-Five9DispositionUpdateResult
{
    <#
    .SYNOPSIS
    
        Function used to get the detailed outcome of using the Add-Five9ListRecord cmdlet
 
    .EXAMPLE
    
        $importId = Add-Five9ListRecord -CsvPath 'c:\files\contacts.csv'

        #
        #    Add-Five9ListRecord will return:
        #
        #    identifier                          
        #    ----------                          
        #    4833baab-9ded-4ade-b131-5263b269bdb9
        #

        Get-Five9ListImportResult -Identifier $importId

        # Returns the result of the contact records import process
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # String returned from Add-Five9ContactRecord. See example.
        [Parameter(Mandatory=$true)][guid]$Identifier
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

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

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning disposition update results using identifier '$($importIdentifier.identifier)'." 
        return $global:DefaultFive9AdminClient.getDispositionsImportResult($importIdentifier)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
