function Remove-Five9ListRecord
{
    <#
    .SYNOPSIS
    
        Function used to remove record(s) from a list

        Using the function you are able to remove records 3 ways:
            1. Specifying a single object using -InputObject
            2. Specifying an arrary of objects using -InputObject
            3. Specifying the path of a local CSV file using -CsvPath
   
    .EXAMPLE
    
        Remove-Five9ContactRecord -ListName 'Hot-Leads' -InputObject $dataToBeRemoved

        # Records in $dataToBeRemoved will be removed from the 'Hot-Leads' list

    .EXAMPLE

        Remove-Five9ContactRecord -ListName 'Hot-Leads' -CsvPath 'C:\files\contact-records.csv'

        # Records in CSV file 'C:\files\contact-records.csv'  will be removed from the 'Hot-Leads' list

    .EXAMPLE

        Remove-Five9ContactRecord -ListName 'Hot-Leads' -CsvPath 'C:\files\contact-records.csv' `
                                  -CrmDeleteMode: DELETE_ALL -Key @('number1', 'first_name') `
                                  -FailOnFieldParseError $true -ReportEmail 'jdoe@domain.com'

        # Removes records in CSV file from the 'Hot-Leads' list, specifying additional optional parameters
    #>
    [CmdletBinding(DefaultParametersetName='InputObject', PositionalBinding=$false)]
    param
    ( 
        # Name of list that records will be removed from
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$ListName,

        # Single object or array of objects to be removed from a list. 
        # Note: Parameter not needed when specifying a CsvPath
        [Parameter(ParameterSetName='InputObject', Mandatory=$true)][psobject[]]$InputObject,

        # Local file path to CSV file containing records to be removed from a list. 
        # Note: Parameter not needed when specifying an InputObject
        [Parameter(ParameterSetName='CsvPath', Mandatory=$true)][string]$CsvPath,

        <#
        Specifies the modes used for deleting records from a list

        Options are:
            • DELETE_ALL (Default) - Delete all specified records
            • DELETE_SOLE_MATCHES - Delete only single matches
            • DELETE_EXCEPT_FIRST - Delete all records except the first matching record
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("DELETE_ALL", "DELETE_SOLE_MATCHES", "DELETE_EXCEPT_FIRST")]$CrmDeleteMode = "DELETE_ALL",

        # Single string, or array of strings which designate key(s). It is used to find matching reocrds in the database to remove.
        # If omitted, 'number1' will be used
        [Parameter(Mandatory=$false)][string[]]$Key = @("number1"),

        <# 
        Whether to stop the removal if incorrect data is found
        For example, if set to True and you have a column named hair_color in your data, but that field has not been created as a contact field, the function will fail

        Options are:
            • True: The record is rejected when at least one field fails validation
            • False: Default. The record is accepted. However, changes to the fields that fail validation are rejected
        #>
        [Parameter(Mandatory=$false)][bool]$FailOnFieldParseError,

        # Notification about results is sent to the email addresses that you set for your application
        [Parameter(Mandatory=$false)][string]$ReportEmail
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

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

        $listDeleteSettings = New-Object PSFive9Admin.listDeleteSettings

        # prepare "fieldMapping" per Five9's documentation
        $counter = 1
        foreach ($header in $headers)
        {
            $isKey = $false
            if ($Key -contains $header)
            {
                $isKey = $true
            }

            $listDeleteSettings.fieldsMapping += @{
                columnNumber = $counter
                fieldName = $header
                key = $isKey
            }

            $counter++

        }

        $csvData = ($csv | select -Skip 1) | Out-String


    
        $listDeleteSettings.listDeleteModeSpecified = $true
        $listDeleteSettings.listDeleteMode = $CrmDeleteMode
    
        if ($PSBoundParameters.Keys -contains "FailOnFieldParseError")
        {
            $listDeleteSettings.failOnFieldParseErrorSpecified = $true
            $listDeleteSettings.failOnFieldParseError = $FailOnFieldParseError
        }

        if ($PSBoundParameters.Keys -contains "ReportEmail")
        {
            $listDeleteSettings.reportEmail = $ReportEmail
        }
    
        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing specified records from list '$ListName'." 

        # single record
        if ($InputObject.Count -eq 1)
        {
            $data = $csvData -replace '"' -split ','
            $response = $global:DefaultFive9AdminClient.deleteFromList($ListName, $listDeleteSettings, $data)  
        }
        else
        {
            $response = $global:DefaultFive9AdminClient.deleteFromListCsv($ListName, $listDeleteSettings, $csvData)
        }

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
