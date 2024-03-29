function Add-Five9ListRecord
{
    <#
    .SYNOPSIS
    
        Function used to add new or existing contact record(s) to an outbound dialing list

        Using the function you are able to add records to a list 3 ways:
            1. Specifying a single object using -InputObject
            2. Specifying an arrary of objects using -InputObject
            3. Specifying the path of a local CSV file using -CsvPath
   
    .EXAMPLE
    
        Add-Five9ListRecord -ListName "Hot-Leads" -InputObject $dataToBeImported

        # Records in $dataToBeImported will be imported into Five9 list named "Hot-Leads" using default values

    .EXAMPLE

        Add-Five9ListRecord -ListName "Hot-Leads" -CsvPath 'C:\files\list-data.csv'

        # Records in CSV file "C:\files\list-data.csv"  will be imported into Five9 list named "Hot-Leads" using default values


    .EXAMPLE 
        Add-Five9ListRecord -ListName "Hot-Leads" -CsvPath 'C:\files\list-data.csv' -TimeToCall '5/5/2022 1:15pm' -TimeToCallColumnName time2call

        # Up to 100 records are uploaded to Hot-Leads list
        # Records that have a value in the "time2call" column will be called at that time, all others will be called at 5/5/2022 1:15pm

    .EXAMPLE
        #

        Add-Five9ListRecord -ListName "Hot-Leads" -CsvPath 'C:\files\list-data.csv' `
                            -CrmAddMode: ADD_NEW -CrmUpdateMode: UPDATE_ALL -ListAddMode: ADD_ALL -Key @('number1', 'first_name') `
                            -CleanListBeforeUpdate: $true -FailOnFieldParseError $true -ReportEmail 'jdoe@domain.com'

        # Imports records from CSV file to list, specifying additional optional parameters
        
    #>
    [CmdletBinding(DefaultParametersetName='InputObject', PositionalBinding=$false)]
    param
    ( 
        # Name of list that records will be added to
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$ListName,

        # Single object or array of objects to be added to list. 
        # Note: Parameter not needed when specifying a CsvPath
        [Parameter(ParameterSetName='InputObject', Mandatory=$true)][psobject[]]$InputObject,

        # Local file path to CSV file containing records to be removed from a list. 
        # Note: Parameter not needed when specifying an InputObject
        [Parameter(ParameterSetName='CsvPath', Mandatory=$true)][string]$CsvPath,

        <#
         Specifies whether a contact record is added to the contact database when a new record is added to a dialing list.

        Options are:
            • ADD_NEW (Default) - Contact records are created in the contact database and are added to the dialing list
            • DONT_ADD - Records are added to the dialing list but no records are created in the contact database
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("ADD_NEW", "DONT_ADD")]$CrmAddMode = "ADD_NEW",

        <#
        Specifies how contact records should be updated when records are added to a dialing list.

        Options are:
            • UPDATE_FIRST (Default) - Update the first matched record
            • UPDATE_SOLE_MATCHES - Update only if one matched record is found
            • UPDATE_ALL - Update all matched records
            • DONT_UPDATE - Do not update any record
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("UPDATE_FIRST", "UPDATE_ALL", "UPDATE_SOLE_MATCHES", "DONT_UPDATE")]$CrmUpdateMode = "UPDATE_FIRST",

        <#
        Specifies how to add records to a list

        Options are:
            • ADD_FIRST (Default) - Adds the first record when multiple matches exist
            • ADD_IF_SOLE_CRM_MATCH - Add record if only one match exists in the database
            • ADD_ALL - Add all records
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("ADD_FIRST", "ADD_ALL", "ADD_IF_SOLE_CRM_MATCH")]$ListAddMode = "ADD_FIRST",

        # Single string, or array of strings which designate key(s). Used when a record needs to be updated, it is used to find the record to update in the contact database.
        # If omitted, 'number1' will be used
        [Parameter(Mandatory=$false)][string[]]$Key = @("number1"),

        # Whether to remove all records in the list before adding new records. If set to True, all existing records will be removed from list before being udpated
        [Parameter(Mandatory=$false)][bool]$CleanListBeforeUpdate,

        <#
            Column number that cotains whether each record should be dialed immediately
            The content of the column should be 1, T, Y, or Yes
            This column is not not imported in the contact database
            If -DialASAPMode parameter is also specified, only records that have a true value will be called immediately
        #>
        [Parameter(Mandatory=$false)][string]$DialASAPColumnName,

        <#
        Setting that defines which records are dialed immediately

        Options are:
            • NONE (Default) - No records are dialed immediately
            • NEW_CRM_ONLY - Newly created CRM records are dialed immediately
            • NEW_LIST_ONLY - New list records are dialed immediately even if the corresponding CRM records existed before the import
            • ANY - All imported records are dialed immediately
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("NONE", "NEW_CRM_ONLY", "NEW_LIST_ONLY", "ANY")]$DialASAPMode,


        <#
            Column name that contains the date and time that a record should be dialed
            This column is not not imported in the contact database
            Some examples values that could be in the column:
                • 2022-04-29 3:05pm
                • 4/29/22 9am
                • Apr 29 2022 15:30

            Note: Pass date and time in your computer's local time zone. Conversion to UTC will happen automatically based on your computer's timezone
            Note: When using this parameter, only 100 records can be uploaded at a time
        #>
        [Parameter(Mandatory=$false)][string]$TimeToCallColumnName,

        <#
            Column name that contains the date and time a record should be dialed 
            Applies to all records in the request, EXCEPT for those with a value in the -TimeToCallColumnName
            The call time value is applied only if the campaign exists when the record is added to the list assigned to that campaign, However, if a
            campaign is created or associated with a list after the record is added to the list, calls may be dialed sooner than the specified value,
            depending on the size of the list, the position of the record in the list, and the other parameters assigned to the list in the campaign
            Some examples values that can be passed to this parameter:
                • 2022-04-29 3:05pm
                • 4/29/22 9am
                • Apr 29 2022 15:30

            Note: Pass date and time in your computer's local time zone. Conversion to UTC will happen automatically based on your computer's timezone
            Note: When using this parameter, only 100 records can be uploaded at a time
        #>
        [Parameter(Mandatory=$false)][datetime]$TimeToCall,

        <#
        Whether to stop the import if incorrect data is found
        For example, if set to True and you have a column named hair_color in your data, but that field has not been created as a contact field, the list import will fail

        Options are:
            • True: The record is rejected when at least one field fails validation
            • False: Default. The record is accepted. However, changes to the fields that fail validation are rejected
        #>
        [Parameter(Mandatory=$false)][bool]$FailOnFieldParseError,

        # Notification about import results is sent to the email addresses that you set for your application
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


        if ($PSBoundParameters.Keys -contains 'TimeToCallColumnName' -or $PSBoundParameters.Keys -contains 'TimeToCall')
        {
            if ($csv.Count -gt 101)
            {
                throw "Cannot upload more than 100 records when using parameters -TimeToCallColumnName or -TimeToCall"
            }
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


        $listUpdateSettings = New-Object PSFive9Admin.listUpdateSettings


        # prepare "fieldMapping" per Five9's documentation
        $counter = 0
        foreach ($header in $headers)
        {
            $counter++

            if ($PSBoundParameters.Keys -contains 'DialASAPColumnName' -and $header -eq $DialASAPColumnName)
            {
                # skip DialASAPColumnName column
                continue
            }
            elseif ($PSBoundParameters.Keys -contains 'TimeToCallColumnName' -and $header -eq $TimeToCallColumnName)
            {
                # skip TimeToCallColumnName column
                continue
            }

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

        }


        if ($PSBoundParameters.Keys -contains 'DialASAPColumnName')
        {
            if ($headers -notcontains $DialASAPColumnName)
            {
                throw "Error processing parameter ""-DialASAPColumnName"". Input data does not contain a column named ""$DialASAPColumnName""."
            }

            $listUpdateSettings.callNowColumnNumber = $($headers.IndexOf($DialASAPColumnName) + 1)
            $listUpdateSettings.callNowColumnNumberSpecified = $true
        }

        
        if ($PSBoundParameters.Keys -contains 'TimeToCallColumnName')
        {
            if ($headers -notcontains $TimeToCallColumnName)
            {
                throw "Error processing parameter ""-TimeToCallColumnName"". Input data does not contain a column named ""$TimeToCallColumnName""."
            }

            $listUpdateSettings.callTimeColumnNumber = $($headers.IndexOf($TimeToCallColumnName) + 1)
            $listUpdateSettings.callTimeColumnNumberSpecified = $true

            # need to convert date time strings to epoch time
            $csvObjs = $csv | ConvertFrom-Csv

            $rowCount = 0

            foreach ($row in $csvObjs)
            {
                $rowCount++

                $epochTime = $null

                if ($row.$TimeToCallColumnName.Length -gt 0)
                {
                    try 
                    {
                        $epochTime = ConvertTo-EpochDateTime -DateTimeInput $row.$TimeToCallColumnName
                    }
                    catch
                    {
                        throw "Failed to convert string to DateTime. RowNumber: ""$rowCount"", Column: ""$TimeToCallColumnName"", Value: ""$($row.$TimeToCallColumnName)"""
                        #throw "Failed to convert string to DateTime. Row Data: $($csv[$rowCount])"
                    }
                }

                $row.$TimeToCallColumnName = $epochTime
                
            }

            $csv = $csvObjs | ConvertTo-Csv -NoTypeInformation

        }


        $listUpdateSettings.crmAddModeSpecified = $true
        $listUpdateSettings.crmAddMode = $CrmAddMode
    
        $listUpdateSettings.crmUpdateModeSpecified = $true
        $listUpdateSettings.crmUpdateMode = $CrmUpdateMode
    
        $listUpdateSettings.listAddModeSpecified = $true
        $listUpdateSettings.listAddMode = $ListAddMode


        if ($PSBoundParameters.Keys -contains 'DialASAPMode')
        {
            $listUpdateSettings.callNowMode = $DialASAPMode
            $listUpdateSettings.callNowModeSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains 'TimeToCall')
        {
            try
            {
                $timeTocallEpoch = ConvertTo-EpochDateTime -DateTimeInput $TimeToCall
            }
            catch
            {
                throw "Failed to convert -TimeToCall parameter to Epoch time: ""$TimeToCall"""
            }

            $listUpdateSettings.callTime = $timeTocallEpoch
            $listUpdateSettings.callTimeSpecified = $true

        }


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



        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding specified records to list '$ListName'." 


        if ($PSBoundParameters.Keys -contains 'TimeToCallColumnName' -or $PSBoundParameters.Keys -contains 'TimeToCall')
        {
             $toUpload = @()

            foreach ($item in $($csv | select -Skip 1))
            {
                $toUpload += , @($item -replace '"' -split ',')
            }
    
            $response = $global:DefaultFive9AdminClient.asyncAddRecordsToList($ListName, $listUpdateSettings, $toUpload, $null)

            return $response

        }

        # remove header row from csv data
        $csvData = ($csv | select -Skip 1) | Out-String

        # single record
        if ($InputObject.Count -eq 1)
        {
            $data = $csvData -replace '"' -split ','
            $response = $global:DefaultFive9AdminClient.addRecordToList($ListName, $listUpdateSettings, $data)
        }
        else
        {
            $response = $global:DefaultFive9AdminClient.addToListCsv($ListName, $listUpdateSettings, $csvData)
        }

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
