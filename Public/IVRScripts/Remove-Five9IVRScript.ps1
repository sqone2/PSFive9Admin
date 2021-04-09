function Remove-Five9IVRScript
{
    <#
    .SYNOPSIS
    
        Function used to delete an existing IVR script

    .EXAMPLE

        Remove-Five9IVRScript -Name 'Sales-Inbound'
    
        # Deletes existing IVR script

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of new IVR script being deleted
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing IVR script '$Name'."
        $global:DefaultFive9AdminClient.deleteIVRScript($Name)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
