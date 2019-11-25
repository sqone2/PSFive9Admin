<#
.SYNOPSIS
    
    Function used to delete a new Five9 list
 
.DESCRIPTION
 
    Function used to delete a new Five9 list
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Name

    Name of new list to be removed
   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9List -Five9AdminClient $adminClient -Name "Cold-Call-List"

    # Deletes list named "Cold-Call-List"

 
#>
function Add-Five9ListRecord
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$ListName,
        [Parameter(Mandatory=$true)][psobject[]]$InputObject,
        [Parameter(Mandatory=$false)][string[]]$Key = @("number1"),
        [Parameter(Mandatory=$true)][string][ValidateSet("ADD_NEW", "DONT_ADD")]$CrmAddMode,
        [Parameter(Mandatory=$true)][string][ValidateSet("UPDATE_FIRST", "UPDATE_ALL", "UPDATE_SOLE_MATCHES", "DONT_UPDATE")]$CrmUpdateMode,
        [Parameter(Mandatory=$true)][string][ValidateSet("ADD_FIRST", "ADD_ALL", "ADD_IF_SOLE_CRM_MATCH")]$ListAddMode,
        [Parameter(Mandatory=$false)][bool]$CleanListBeforeUpdate,
        [Parameter(Mandatory=$false)][bool]$FailOnFieldParseError,
        [Parameter(Mandatory=$false)][string]$ReportEmail

    )


    try
    {
        $csv = $InputObject | ConvertTo-Csv -NoTypeInformation
    }
    catch
    {
        throw $_
        return
    }


    $headers = $csv[0] -replace '"' -split ','

    # verify that key(s) passed are present in $Inputobject
    foreach ($k in $Key)
    {
        if ($headers -notcontains $key)
        {
            throw "Specified key ""$k"" is not a property name found in -InputObject."
            return
        }
    }

    $listUpdateSettings = New-Object PSFive9Admin.listUpdateSettings

    # prepare "fieldMapping" per Five9's documentation
    $counter = 1
    foreach ($header in $headers)
    {
        $isKey = $false
        if ($Key -contains $header)
        {
            $isKey = $true
        }

        $listUpdateSettings.fieldsMapping += @{
            columnNumber = $counter
            fieldName = $header
            key = $isKey
        }

        $counter++

    }


    $csvData = ($csv | select -Skip 1) | Out-String


    $listUpdateSettings.crmAddModeSpecified = $true
    $listUpdateSettings.crmAddMode = $CrmAddMode
    
    $listUpdateSettings.crmUpdateModeSpecified = $true
    $listUpdateSettings.crmUpdateMode = $CrmUpdateMode
    
    $listUpdateSettings.listAddModeSpecified = $true
    $listUpdateSettings.listAddMode = $ListAddMode
    

    if ($PSBoundParameters.Keys -contains "CleanListBeforeUpdate")
    {
        $listUpdateSettings.cleanListBeforeUpdate = $CleanListBeforeUpdate
    }

    if ($PSBoundParameters.Keys -contains "FailOnFieldParseError")
    {
        $listUpdateSettings.failOnFieldParseErrorSpecified = $true
        $listUpdateSettings.failOnFieldParseError = $FailOnFieldParseError
    }

    if ($PSBoundParameters.Keys -contains "ReportEmail")
    {
        $listUpdateSettings.reportEmail = $ReportEmail
    }
    

    # single record
    if ($InputObject.Count -eq 1)
    {
        $data = $csvData -replace '"' -split ','
        $response = $Five9AdminClient.addRecordToList($ListName, $listUpdateSettings, $data)
        return $response
                
    }
    else
    {
        $response = $Five9AdminClient.addToListCsv($ListName, $listUpdateSettings, $csvData)
        return $response
    }





}

$list =@(
$(New-Object psobject -Property @{
    number1 = "6156910079"
    first_name = "Steve"
    last_name = "Quirion"
}),
$(New-Object psobject -Property @{
    number1 = "6157321501"
    first_name = "Desk"
    last_name = "Phone"
})


)


$list =@(
$(New-Object psobject -Property @{
    number1 = "6157321501"
    first_name = "Desk"
    last_name = "Phone"
})


)

