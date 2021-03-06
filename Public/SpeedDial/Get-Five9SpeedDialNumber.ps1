function Get-Five9SpeedDialNumber
{
    <#
    .SYNOPSIS
    
        Function used to return a list of speed dial numbers
   
    .EXAMPLE
    
        Get-Five9SpeedDialNumbers
    
        # Returns all speed dial numbers
    #>
    [CmdletBinding()]
    param
    ( 
    )
    
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning all speed dial numbers." 
        return $global:DefaultFive9AdminClient.getSpeedDialNumbers() | sort code

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}

