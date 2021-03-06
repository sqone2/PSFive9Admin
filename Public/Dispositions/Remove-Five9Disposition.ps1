function Remove-Five9Disposition
{
    <#
    .SYNOPSIS
    
        Function used to delete a Five9 disposition
   
    .EXAMPLE
    
        Remove-Five9Disposition -Name "Default-Disposition"

        # Deletes existing disposition named "Default-Disposition"
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of existing disposition to be removed
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing disposition '$Name'." 
        $response = $global:DefaultFive9AdminClient.removeDisposition($Name)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
