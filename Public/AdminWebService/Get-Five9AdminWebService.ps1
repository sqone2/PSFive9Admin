function Get-Five9AdminWebService
{
    <#
    .SYNOPSIS
    
        Function used to return connection status to Five9 admin web service

    .EXAMPLE
    
        Get-Five9AdminWebService
    
        # Returns connection status

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (

    )

    try
    {
        Test-Five9Connection

        return $DefaultFive9AdminClient | select Five9DomainName,Five9DomainId,Url,@{n="Username";e={$DefaultFive9AdminClient.Credentials.UserName}},Version,DataCenter

    }
    catch
    {
        throw $_
        return
    }

}

