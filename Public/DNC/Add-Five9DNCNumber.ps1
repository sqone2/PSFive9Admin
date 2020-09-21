function Add-Five9DNCNumber
{
    <#
    .SYNOPSIS
    
        Function used to add phone number(s) to your domain’s do-not-call (DNC) list
   
    .EXAMPLE
    
        Add-Five9DNCNumber -Number '8005551212'
    
        # Adds a single number to the DNC list
    
    .EXAMPLE
    
        Add-Five9DNCNumber -Number @('8005551212', '3215551212')
    
        # Adds multiple numbers to the DNC list
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # One or more numbers to be added to the DNC list
        [Parameter(Mandatory=$true)][string[]]$Number
    )
    
    try
    {

        Test-Five9Connection -ErrorAction: Stop

        if ($Number.Count -eq 1)
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Adding '$Number' to the DNC list."
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Adding $($Number.Count) numbers to the DNC list."
        }
        
        return $global:DefaultFive9AdminClient.addNumbersToDnc($Number)

    }
    catch
    {
        throw $_
    }
}
