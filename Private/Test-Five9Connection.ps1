function Test-Five9Connection
{
    <#
    .SYNOPSIS
    
        Function used to test connection to Five9 admin web service


    .EXAMPLE
    
        Test-Five9Connection
    
        # Will throw expection if not connected to Five9 admin web service
    
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (

    )

    if ($global:DefaultFive9AdminClient.Five9DomainName.Length -gt 0)
    {
        return
    }

    throw "You are not currently connected to the Five9 Admin Web Service. You must first connect using Connect-Five9AdminWebService."
    return

}

        