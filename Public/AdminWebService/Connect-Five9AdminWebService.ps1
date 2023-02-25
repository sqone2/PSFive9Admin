﻿function Connect-Five9AdminWebService
{
    <#
    .SYNOPSIS

        Function used to create a web service proxy with the Five9 admin web service

    .EXAMPLE

        Connect-Five9AdminWebService

        # User will be prompted to enter Five9 username and password, and then be connected to Five9 admin web service

    .EXAMPLE

        Connect-Five9AdminWebService -DataCenter "EU"

        # Domain being connected to is loacated in the Five9 EU data center

    .EXAMPLE
        #
        $username = 'jdoe@domain.com'
        $password = 'P@ssword!' | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object -TypeName PSCredential -ArgumentList $username,$password
        Connect-Five9AdminWebService -Credential $cred

        # Create PSCredential object and connects to Five9 admin web service

    #>
    [CmdletBinding(PositionalBinding = $false)]
    param
    (
        # PSCredential object, such as one returned by the Get-Credential cmdlet.
        # If parameter is omitted, Get-Credential will be called.
        [Parameter(Mandatory = $false, Position = 0)][PSCredential]$Credential = (Get-Credential -Message "Please enter your Five9 admin credentials"),

        # Optional API version. See Five9 documentation for details on what is provided with each version.
        # If omitted, most recent version will be used (recommended).
        [Parameter(Mandatory = $false)][string]$Version = '12',

        <#
        Data center that contains the Five9 domain you are connecting to

        Options are:
            • US (Default) - United States data center - api.five9.eu
            • EU - European Union data center (UK) - api.five9.eu
            • EU_Frankfurt - European Union data center (Frankfurt) - api.eu.five9.com
            • Canada - Canada Data center - api.five9.ca
        #>
        [Parameter(Mandatory = $false)][ValidateSet('US', 'EU', 'EU_Frankfurt', 'Canada')][string]$DataCenter = 'US'

    )

    try
    {
        $commandCheck = Get-Command New-WebServiceProxy -ErrorAction Ignore
    }
    catch
    {

    }

    if ($DataCenter -eq 'US')
    {
        $baseUrl = 'https://api.five9.com'
    }
    elseif ($DataCenter -eq 'EU')
    {
        $baseUrl = "https://api.five9.eu"
    }
    elseif ($DataCenter -eq 'EU_Frankfurt')
    {
        $baseUrl = "https://api.eu.five9.com"
    }
    elseif ($DataCenter -eq 'Canada')
    {
        $baseUrl = "https://api.five9.ca"
    }
    else
    {
        $baseUrl = 'https://api.five9.com'
    }


    # need to determine if user is using powershell core
    if ($PSVersionTable.PSVersion.Major -gt 7 -or $null -eq $commandCheck)
    {
        # REST API

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        if ($Credential.UserName.Length -lt 1 -or $Credential.GetNetworkCredential().password.Length -lt 1)
        {
            throw "Error connecting to Five9 admin web service. Username or password was null."
            return
        }

        if ($PSBoundParameters.Keys -notcontains $Version)
        {
            $Version = '1'
        }

        $getDomainResp = Invoke-Five9RestApi `
            -Credential $Credential `
            -BaseUrl $baseUrl `
            -Method 'GET' `
            -Path 'system-settings' `
            -Version $Version

        $global:DefaultFive9AdminClient = New-Object psobject -Property @{
            API = 'Five9 Admin REST'
            Credential = [PSCredential]$Credential
            Five9DomainName = $getDomainResp.domainName
            Five9DomainId = $getDomainResp.domainId
            Version = $Version
            DataCenter = $null
            BaseUrl = $baseUrl
        }

        Write-Verbose "Connection established to domain id $($getDomainResp.domainId) ($($getDomainResp.domainName))"

    }
    else
    {
        # legcay SOAP API

        try
        {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            if ($Credential.UserName.Length -lt 1 -or $Credential.GetNetworkCredential().password.Length -lt 1)
            {
                throw "Error connecting to Five9 admin web service. Username or password was null."
                return
            }

            $wsdl = "$baseUrl/wsadmin/v$($Version)/AdminWebService?wsdl&user=$($Credential.Username)"


            Write-Verbose "Connecting to: $($wsdl)"

            $global:DefaultFive9AdminClient = New-WebServiceProxy -Uri $wsdl -Namespace "PSFive9Admin" -Class "PSFive9Admin" -ErrorAction: Stop

            $global:DefaultFive9AdminClient.Credentials = $Credential
            $global:DefaultFive9AdminClient.Credentials.UserName = $Credential.UserName
            $global:DefaultFive9AdminClient.Credentials.Domain = $null

            $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name Five9DomainName -Value $null -Force
            $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name Five9DomainId -Value $null -Force
            $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name Version -Value $null -Force
            $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name DataCenter -Value $null -Force
            $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name BaseUrl -Value $baseUrl -Force
            $global:DefaultFive9AdminClient | Add-Member -MemberType NoteProperty -Name API -Value 'Five9 Admin SOAP' -Force

            $global:DefaultFive9AdminClient.Timeout = 1000000

        }
        catch
        {
            throw "Error creating web service proxy to Five9 Admin Web Service. $($_.Exception.Message)"
            return
        }

        # test credentails
        try
        {
            $vccConfig = $global:DefaultFive9AdminClient.getVCCConfiguration()
            Write-Verbose "Connection established to domain id $($vccConfig.domainId) ($($vccConfig.domainName))"

            $global:DefaultFive9AdminClient.Five9DomainName = $vccConfig.domainName
            $global:DefaultFive9AdminClient.Five9DomainId = $vccConfig.domainId
            $global:DefaultFive9AdminClient.Version = $Version
            $global:DefaultFive9AdminClient.DataCenter = $DataCenter

        }
        catch
        {
            $errorMessage = ($_.Exception.Message) -replace 'Exception calling "getVCCConfiguration" with "0" argument\(s\)\: '
            throw "Error connecting to Five9 admin web service. Please check your credentials and try again. $errorMessage"
            return
        }

    }




}

