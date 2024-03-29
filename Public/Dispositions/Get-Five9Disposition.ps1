function Get-Five9Disposition
{
    <#
    .SYNOPSIS
    
        Function used to get disposition(s) from Five9

    .EXAMPLE
    
        Get-Five9Disposition
    
        # Returns all dispositions
    
    .EXAMPLE
    
        Get-Five9Disposition -NamePattern "No Answer"
    
        # Returns disposition named "No Answer"
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Optional parameter. Returns only dispositions matching a given regex string
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning custom dispositions using pattern '$NamePattern'" 
        return $global:DefaultFive9AdminClient.getDispositions($NamePattern) | sort name

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
