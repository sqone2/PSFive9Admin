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
        [Parameter(Mandatory = $false, Position = 0)][ValidateSet('REST', 'SOAP')][string]$ApiName
    )

    if ($global:DefaultFive9AdminClient.API -match 'REST' -and $ApiName -notmatch 'REST')
    {
        # user is using powershell core
        # do not allow legacy commands

        throw "Sorry but your version of PowerShell ($($PSVersionTable.PSVersion)) is too new for this command, and has not yet been migrated to the new REST API. Please check for updates as they're released!"


    }

    if ($global:DefaultFive9AdminClient.Five9DomainName.Length -gt 0)
    {
        return
    }

    throw "You are not currently connected to the Five9 Admin Web Service. You must first connect using Connect-Five9AdminWebService."
    return

}

