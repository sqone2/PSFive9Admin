function Connect-Five9AdminWebService
{
    <#
    .SYNOPSIS
    
        Function used to create a web service proxy with the Five9 admin web service

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
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # PSCredential object, such as one returned by the Get-Credential cmdlet.
        # If parameter is omitted, Get-Credential will be called.
        [Parameter(Mandatory=$false, Position=0)][PSCredential]$Credential = (Get-Credential),

        # Optional API version. See Five9 documentation for details on what is provided with each version. 
        # If omitted, most recent version will be used (recommended).
        [Parameter(Mandatory=$false)][string]$Version = '11',

        # Whether to connect to EU data center. If omitted, or set to $false, you will be connected to a US data center
        [Parameter(Mandatory=$false)][string]$EuDomain = $false,

        # Returns an object that contains the web service proxy
        [Parameter(Mandatory=$false)][switch]$PassThru = $false
    )

    try
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        if ($EuDomain -eq $true)
        {
            $wsdl = "https://api.five9.eu/wsadmin/v$($Version)/AdminWebService?wsdl&user=$($Credential.Username)"
        }
        else
        {
            $wsdl = "https://api.five9.com/wsadmin/v$($Version)/AdminWebService?wsdl&user=$($Credential.Username)"
        }
        

        Write-Verbose "Connecting to: $($wsdl)"

        $global:DefaultFive9AdminClient = New-WebServiceProxy -Uri $wsdl -Namespace "PSFive9Admin" -Class "PSFive9Admin" -ErrorAction: Stop

        $global:DefaultFive9AdminClient.Credentials = $Credential
        $global:DefaultFive9AdminClient.Credentials.UserName = $Credential.UserName
        $global:DefaultFive9AdminClient.Credentials.Domain = $null

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
        $vccConfig = $global:DefaultFive9AdminClient.getVCCConfiguration()
        Write-Verbose "Connection established to domain id $($vccConfig.domainId) ($($vccConfig.domainName))"

        $global:DefaultFive9AdminClient.Five9DomainName = $vccConfig.domainName
        $global:DefaultFive9AdminClient.Five9DomainId = $vccConfig.domainId

    }
    catch
    {
        $errorMessage = ($_.Exception.Message) -replace 'Exception calling "getVCCConfiguration" with "0" argument\(s\)\: '
        throw "Error connecting to Five9 admin web service. Please check your credentials and try again. $errorMessage"
        return
    }


    if ($PassThru -eq $true)
    {
        return $global:DefaultFive9AdminClient
    }

    return

}

