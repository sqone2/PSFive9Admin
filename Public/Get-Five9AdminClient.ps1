function Get-Five9AdminClient
{
    param
    (
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password
    )

    $wsdl = "https://api.five9.com/wsadmin/v11/AdminWebService?wsdl&user=$Username"
    $proxy = New-WebServiceProxy -Uri $wsdl
    $proxy.Credentials = $(New-Object System.Net.NetworkCredential($Username, $Password))

    return $proxy

}




