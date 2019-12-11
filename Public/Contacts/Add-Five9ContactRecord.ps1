<#
.SYNOPSIS
    
    Function used to add a record(s) to the Five9 contact record database

    Using the function you are able to add records 3 ways:
        1. Specifying a single object using -InputObject
        2. Specifying an arrary of objects using -InputObject
        3. Specifying the path of a local CSV file using -CsvPath
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER InputObject

    Single object or array of objects to be added to contact record database. Note: Parameter not needed when specifying a CsvPath

.PARAMETER CsvPath
    
    Local file path to CSV file. Note: Parameter not needed when specifying an InputObject

.PARAMETER CrmAddMode

    Specifies whether a contact record is added to the contact database

    Options are:
        • ADD_NEW (Default) - New contact records are created in the contact database
        • DONT_ADD - New contact records are not created in the contact database

.PARAMETER CrmUpdateMode

    Specifies how contact records should be updated

    Options are:
        • UPDATE_SOLE_MATCHES (Default) - Update only if one matched record is found
        • UPDATE_FIRST - Update the first matched record
        • UPDATE_ALL - Update all matched records
        • DONT_UPDATE - Do not update any record
        
.PARAMETER Key

    Single string, or array of strings which designate key(s). Used when a record needs to be updated, it is used to find the record to update in the contact database.
    If omitted, 'number1' will be used


.PARAMETER FailOnFieldParseError

    Whether to stop the import if incorrect data is found
    For example, if set to True and you have a column named hair_color in your data, but that field has not been created as a contact field, the import will fail

    Options are:
    • True: The record is rejected when at least one field fails validation
    • False: Default. The record is accepted. However, changes to the fields that fail validation are rejected


.PARAMETER ReportEmail

    Notification about import results is sent to the email addresses that you set for your application
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Add-Five9ContactRecord -Five9AdminClient $adminClient -InputObject $dataToBeImported

    # Records in $dataToBeImported will be imported into the contact record database

.EXAMPLE

    Add-Five9ContactRecord -Five9AdminClient $adminClient -CsvPath 'C:\files\contact-records.csv'

    # Records in CSV file 'C:\files\contact-records.csv'  will be imported into the contact record database

.EXAMPLE

    Add-Five9ContactRecord -Five9AdminClient $adminClient -CsvPath 'C:\files\contact-records.csv' `
                           -CrmAddMode: ADD_NEW -CrmUpdateMode: UPDATE_ALL -Key @('number1', 'first_name') `
                           -FailOnFieldParseError $true -ReportEmail 'jdoe@domain.com'

    # Importing CSV file to contact record database, specifying additional optional parameters


#>
function Add-Five9ContactRecord
{
    [CmdletBinding(DefaultParametersetName='InputObject', PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(ParameterSetName='InputObject', Mandatory=$true)][psobject[]]$InputObject,
        [Parameter(ParameterSetName='CsvPath', Mandatory=$true)][string]$CsvPath,
        [Parameter(Mandatory=$false)][string][ValidateSet("ADD_NEW", "DONT_ADD")]$CrmAddMode = "ADD_NEW",
        [Parameter(Mandatory=$false)][string][ValidateSet("UPDATE_FIRST", "UPDATE_ALL", "UPDATE_SOLE_MATCHES", "DONT_UPDATE")]$CrmUpdateMode = "UPDATE_SOLE_MATCHES",
        [Parameter(Mandatory=$false)][string[]]$Key = @("number1"),
        [Parameter(Mandatory=$false)][bool]$FailOnFieldParseError,
        [Parameter(Mandatory=$false)][string]$ReportEmail
    )

    try
    {
        if ($PSCmdlet.ParameterSetName -eq 'InputObject')
        {
            $csv = $InputObject | ConvertTo-Csv -NoTypeInformation
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'CsvPath')
        {
            # try to import csv file so that if it throw an error, we know the data is bad
            $csv = Import-Csv $CsvPath | ConvertTo-Csv -NoTypeInformation
        }
        else
        {
            # should never reach this point becasue user should use either InputObject or CsvPath
            return
        }
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
        if ($headers -notcontains $k)
        {
            throw "Specified key ""$k"" is not a property name found in data being imported."
            return
        }
    }


    $crmUpdateSettings = New-Object PSFive9Admin.crmUpdateSettings

    # prepare "fieldMapping" per Five9's documentation
    $counter = 1
    foreach ($header in $headers)
    {
        $isKey = $false
        if ($Key -contains $header)
        {
            $isKey = $true
        }

        $crmUpdateSettings.fieldsMapping += @{
            columnNumber = $counter
            fieldName = $header
            key = $isKey
        }

        $counter++

    }


    $csvData = ($csv | select -Skip 1) | Out-String


    $crmUpdateSettings.crmAddModeSpecified = $true
    $crmUpdateSettings.crmAddMode = $CrmAddMode
    
    $crmUpdateSettings.crmUpdateModeSpecified = $true
    $crmUpdateSettings.crmUpdateMode = $CrmUpdateMode
    
    if ($PSBoundParameters.Keys -contains "FailOnFieldParseError")
    {
        $crmUpdateSettings.failOnFieldParseErrorSpecified = $true
        $crmUpdateSettings.failOnFieldParseError = $FailOnFieldParseError
    }

    if ($PSBoundParameters.Keys -contains "ReportEmail")
    {
        $crmUpdateSettings.reportEmail = $ReportEmail
    }
    

    # single record
    if ($InputObject.Count -eq 1)
    {
        $data = $csvData -replace '"' -split ','
        $response = $Five9AdminClient.updateContacts($crmUpdateSettings, $data)
        return $response
                
    }
    else
    {
        $response = $Five9AdminClient.updateContactsCsv($crmUpdateSettings, $csvData)
        return $response
    }


}
