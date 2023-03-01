function Invoke-Five9RestApi
{
    <#
    .SYNOPSIS

        Invokes Five9 REST API. To be used as a helper function is cmdlets

    .EXAMPLE

        Invoke-Five9RestApi -Method GET -Path 'system-settings'

        # Returns domain system settings

    #>
    [CmdletBinding(PositionalBinding = $false)]
    param
    (
        # Http Method to be used in API call
        [Parameter(Mandatory = $true)][ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')][string]$Method,

        # Path/endpoint to be used in API call
        [Parameter(Mandatory = $true)][string]$Path,

        # Five9 domain credentials
        # If omitted, creds captured using Connect-Five9AdminWebService will be used
        [Parameter(Mandatory = $false)][pscredential]$Credential,

        # Five9 domain base URL based on Five9 datacenter
        # If omitted, -DataCenter value captured using Connect-Five9AdminWebService will be used
        [Parameter(Mandatory = $false)][string]$BaseUrl,

        # Five9 API Version
        # If omitted, -Version value captured using Connect-Five9AdminWebService will be used
        [Parameter(Mandatory = $false)][string]$Version = '1',

        # Hashtable or Json string to be sent in API call
        # Parameter is ignored if request is 'GET'
        [Parameter(Mandatory = $false)][object]$Body,

        # Hashtable of key/value pairs to be passed as query string parameters in the API URL
        [Parameter(Mandatory = $false)][hashtable]$QueryParams = @{}

    )

    try
    {

        if ($PSBoundParameters.Keys -notcontains 'Credential')
        {
            $Credential = $DefaultFive9AdminClient.Credentials
        }

        if ($PSBoundParameters.Keys -notcontains 'BaseUrl')
        {
            if ($DefaultFive9AdminClient.BaseUrl -match 'https')
            {
                $BaseUrl = $DefaultFive9AdminClient.BaseUrl
            }
            else
            {
                throw "Invalid BaseUrl"
            }
        }

        if ($Credential.UserName.Length -lt 1)
        {
            throw "Invalid credentials."
        }

        $headers = @{}
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credential.UserName, $Credential.GetNetworkCredential().Password)))

        $headers += @{
            Authorization = "Basic $base64Auth"
        }

        $jsonBody = $null
        if ($Method -match 'POST|PUT|PATCH')
        {
            if ($null -ne $Body)
            {
                if ($Body.GetType().Name -eq 'String')
                {
                    # already JSON (string)
                    # convert to compress
                    $jsonBody = $Body | ConvertFrom-Json -Depth 20 | ConvertTo-Json -Depth 20 -Compress
                }
                else
                {
                    # needs to be converted to json string
                    $jsonBody = $Body | ConvertTo-Json -Compress -Depth 20
                }
            }

            Write-Debug "JSON Body: $jsonBody"
        }
        elseif ($Method -eq 'GET')
        {
            $limitSpecified = $false
            $originalLimit = 0

            if ($QueryParams.Keys -notcontains 'offset')
            {
                $QueryParams += @{
                    offset = 0
                }
            }

            [int]$originalLimit = 0

            if ($QueryParams.Keys -notcontains 'limit')
            {
                $QueryParams += @{
                    limit = 100
                }
            }
            else
            {

                # limit already passed
                $limitSpecified = $true
                $originalLimit = [int]$QueryParams.limit

                if ($QueryParams.limit -gt 100)
                {
                    $QueryParams.limit = 100
                }

            }
        }

        if ($Path -match '^/')
        {
            $Path = $Path -replace '^/', ''
        }

        $request = [System.UriBuilder]$BaseUrl
        $request.Path = "/restadmin/api/v$Version/domains/me/$Path"
        $request.Query = Get-QueryParamString $QueryParams


        while ($true)
        {
            Write-Debug "$($MyInvocation.MyCommand.Name): $($Method): ""$($request.Uri)"""

            $response = Invoke-WebRequest `
                -Uri $request.Uri `
                -Method $Method `
                -Headers $headers `
                -Body $jsonBody `
                -ContentType 'application/json' `
                -Verbose: $false `
                -ErrorAction: Stop

            Write-Debug "Response: $($response.StatusCode) $($response.StatusDescription)"

            $respContent = $null

            if ($response.Content.Length -gt 0)
            {
                $respContent = $response | ConvertFrom-Json -Depth 50
            }

            if ($null -eq $respContent.entities -or $Method -ne 'GET')
            {
                return $respContent
            }

            ## get all results using pagination

            $returnObj += $respContent.entities
            Write-Debug "Total returned: $($returnObj.Count)"

            if ($respContent.entities.Count -lt $QueryParams.limit)
            {
                break
            }

            if ($limitSpecified)
            {
                if ($returnObj.Count -ge $originalLimit)
                {
                    break
                }

                $QueryParams.offset += $returnObj.Count
                $QueryParams.limit = $originalLimit - $returnObj.Count
                $request.Query = Get-QueryParamString $QueryParams
                continue
            }

            $QueryParams.offset += $QueryParams.limit
            $request.Query = Get-QueryParamString $QueryParams
            continue
        }

        return $returnObj


    }
    catch
    {
        $_ | Write-PSFive9AdminError
        $_ | Write-Error
    }

}
