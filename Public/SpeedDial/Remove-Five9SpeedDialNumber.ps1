function Remove-Five9SpeedDialNumber
{
    <#
    .SYNOPSIS
    
        Function used to remove a speed dial number
   
    .EXAMPLE
    
        Remove-Five9SpeedDialNumber -Code 6
    
        # Removes speed dial number with code '6'
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Code assigned to the speed dial number
        [Parameter(Mandatory=$true)][string]$Code
    )

    
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing speed dial number with code '$Code'." 
        return $global:DefaultFive9AdminClient.removeSpeedDialNumber($Code)

    }
    catch
    {
        throw $_
    }
}