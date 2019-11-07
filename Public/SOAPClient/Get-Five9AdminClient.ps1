function Get-Five9AdminClient
{
    param
    (
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password
    )

    # get soap client
    $wsdl = "https://api.five9.com/wsadmin/v11/AdminWebService?wsdl&user=$Username"
    $proxy = New-WebServiceProxy -Uri $wsdl -Namespace "PSFive9Admin"
    $proxy.Credentials = $(New-Object System.Net.NetworkCredential($Username, $Password))


    # test credentails
    try
    {
        $test = $proxy.getUserGeneralInfo($Username)
    }
    catch
    {
        throw "Error connecting to Five9 Web Service. Please check your credentials and try again. $($_.Exception.Message)"
    }

    return $proxy

}

