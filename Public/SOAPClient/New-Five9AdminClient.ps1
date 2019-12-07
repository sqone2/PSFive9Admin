<#
.SYNOPSIS
    
    Function used to create SOAP Proxy with Five9 Web Admin Web Service API

.PARAMETER Username
 
    Mandatory parameter. Five9 Admin Username

.PARAMETER Password
 
    Mandatory parameter. Five9 Admin Password
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    
    # Returns SOAP Proxy with Five9 Web Admin Web Service API

 
#>
function New-Five9AdminClient
{
    param
    (
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password
    )

    # get soap client
    try
    {
        $wsdl = "https://api.five9.com/wsadmin/v11/AdminWebService?wsdl&user=$Username"
        $proxy = New-WebServiceProxy -Uri $wsdl -Namespace "PSFive9Admin" -Class "PSFive9Admin"
        $proxy.Credentials = $(New-Object System.Net.NetworkCredential($Username, $Password))
    }
    catch
    {
        throw "Error creating web service proxy to Five9 web service. $($_.Exception.Message)"
    }
    
    # test credentails
    try
    {
        $test = $proxy.getUserGeneralInfo($Username)
    }
    catch
    {
        throw "Error connecting to Five9 web service. Please check your credentials and try again. $($_.Exception.Message)"
    }

    return $proxy

}

