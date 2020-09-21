function Remove-Five9DNCNumber
{
    <#
    .SYNOPSIS
    
        Function used to remove phone number(s) from your domain’s do-not-call (DNC) list
   
    .EXAMPLE
    
        Remove-Five9DNCNumber -Number '8005551212'
    
        # Removes a single number from the DNC list
    
    .EXAMPLE
    
        Remove-Five9DNCNumber -Number @('8005551212', '3215551212')
    
        # Removes multiple numbers from the DNC list
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # One or more numbers to be removed from the DNC list
        [Parameter(Mandatory=$true)][string[]]$Number
    )
    
    try
    {

        Test-Five9Connection -ErrorAction: Stop

        if ($Number.Count -eq 1)
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Removing '$Number' from the DNC list."
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Removing $($Number.Count) numbers from the DNC list."
        }
        
        return  $global:DefaultFive9AdminClient.removeNumbersFromDnc($Number)

    }
    catch
    {
        throw $_
    }
}
