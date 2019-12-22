<#
.SYNOPSIS
    
    Function used to create a web service proxy with the Five9 admin web service

.PARAMETER Credential
 
    PSCredential object, such as one returned by the Get-Credential cmdlet.
    If parameter is omitted, Get-Credential will be called.

.PARAMETER Version
 
    Optional API version. See Five9 documentation for details on what is provided with each version. 
    If omitted, most recent version will be used (recommended).

.PARAMETER PassThru
 
    Returns an object that contains the web service proxy

.EXAMPLE
    
    Connect-Five9AdminWebService
    
    # User will be prompted to enter Five9 username and password, and then be connected to Five9 admin web service

.EXAMPLE

    $username = "jdoe@domain.com"
    $password = 'P@ssword!' | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object -TypeName PSCredential -ArgumentList $username,$password
    Connect-Five9AdminWebService -Credential $cred
    
    # Create PSCredential object and connects to Five9 admin web service

#>
function Connect-Five9AdminWebService
{
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        [Parameter(Mandatory=$false)][PSCredential]$Credential = (Get-Credential),
        [Parameter(Mandatory=$false)][string]$Version = '11',
        [Parameter(Mandatory=$false)][switch]$PassThru = $false
    )

    try
    {
        try
        {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        }
        catch
        {

        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $wsdl = "https://api.five9.com/wsadmin/v$($Version)/AdminWebService?wsdl&user=$($Credential.Username)"
        Write-Verbose "Connecting to: $($wsdl)"

        $global:DefaultFive9AdminClient = New-WebServiceProxy -Uri $wsdl -Namespace "PSFive9Admin" -Class "PSFive9Admin" -ErrorAction: Stop

        $global:DefaultFive9AdminClient.Credentials = $Credential

        $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name Five9DomainName -Value $null -Force
        $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name Five9DomainId -Value $null -Force

    }
    catch
    {
        throw "Error creating web service proxy to Five9 admin web service. $($_.Exception.Message)"
        return
    }
    
    # test credentails
    try
    {
        $vccConfig = $script:DefaultFive9AdminClient.getVCCConfiguration()
        Write-Verbose "Connection established to domain id $($vccConfig.domainId) ($($vccConfig.domainName))"

        $global:DefaultFive9AdminClient.Five9DomainName = $vccConfig.domainName
        $global:DefaultFive9AdminClient.Five9DomainId = $vccConfig.domainId

    }
    catch
    {
        throw "Error connecting to Five9 admin web service. Please check your credentials and try again. $($_.Exception.Message)"
        return
    }


    if ($PassThru -eq $true)
    {
        return $global:DefaultFive9AdminClient
    }

    return

}

