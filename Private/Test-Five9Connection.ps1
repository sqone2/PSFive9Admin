<#
.SYNOPSIS
    
    Function used to test AdminClient type

.PARAMETER AdminClient
 
    Optional parameter containing web service proxy object returned by calling Connect-Five9AdminWebService -PassThru

.EXAMPLE
    
    Test-Five9Connection -AdminClient $AdminClient
    
    # Will return AdminClient if it's valid. Or will throw exception
    
#>
function Test-Five9Connection
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    (

    )

    if ($global:DefaultFive9AdminClient.Five9DomainName.Length -gt 0)
    {
        return
    }

    throw "You are not currently connected to the Five9 admin web service. You must first connect using Connect-Five9AdminWebService."
    return

}

        