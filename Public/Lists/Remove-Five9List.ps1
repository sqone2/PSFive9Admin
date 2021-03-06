function Remove-Five9List
{
    <#
    .SYNOPSIS
    
        Function used to delete a new Five9 list

    .EXAMPLE
    
        Remove-Five9List -Name "Cold-Call-List"

        # Deletes list named "Cold-Call-List"
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of new list to be removed
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing list '$Name'." 

        return $global:DefaultFive9AdminClient.deleteList($Name)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}

