function Update-Five9CampaignDisposition
{
    <#
    .SYNOPSIS
    
        Function used to updates batches of disposition values in a campaign

        Using the function you are able to add records to a list 3 ways:
            1. Specifying a single object using -InputObject
            2. Specifying an arrary of objects using -InputObject
            3. Specifying the path of a local CSV file using -CsvPath
   
    .EXAMPLE

        Update-Five9CampaignDisposition -CampaignName 'Hot-Leads' -CsvPath 'C:\files\dispo-update-records.csv' -CommonDispositionValue 'No Answer'

        # Records in CSV file "C:\files\dispo-update-records.csv" will update their disposition to 'No Answer'

    .EXAMPLE
        #
        $recordsToUpdate = @()

        $recordsToUpdate += New-Object psobject -Property @{
            number1 = '3215551212'
            first_name = 'Steve'
            newDispo = 'No Answer'
        }

        $recordsToUpdate += New-Object psobject -Property @{
            number1 = '3214440202'
            first_name = 'Dan'
            newDispo = 'No Answer'
        }

        Update-Five9CampaignDisposition -CampaignName 'Hot-Leads' -InputObject $recordsToUpdate -DispositionColumnName 'newDispo'

        # Records in $dataToBeImported will be update their disposition using the value in the column names 'newDispo'

    .EXAMPLE
        #
        $importId = Update-Five9CampaignDisposition -CampaignName 'Hot-Leads' -CsvPath 'C:\files\dispo-update-records.csv' `
                            -DispositionColumnName 'updatedDisposition' -DispositionsUpdateMode 'UPDATE_IF_SOLE_CRM_MATCH' `
                            -Key @('number1','salesforce_id') -FailOnFieldParseError $true -ReportEmail 'jdoe@domain.com' -Verbose

        # Records in CSV file will update their dispostion to the value in the column 'updatedDisposition'  
        # Records will only be updated if an exact match is found in the 'number1' and 'salesforce_id' contact fields

        $results = Get-Five9DispositionUpdateResult -Identifier $importId
    #>


    [CmdletBinding(DefaultParametersetName='InputObject', PositionalBinding=$false)]
    param
    ( 

        # Name of list that records will be added to
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$CampaignName,

        # Single object or array of objects to be added to list. 
        # Note: Parameter not needed when specifying a CsvPath
        [Parameter(ParameterSetName='InputObject', Mandatory=$true)][psobject[]]$InputObject,

        # Local file path to CSV file containing records to be removed from a list. 
        # Note: Parameter not needed when specifying an InputObject
        [Parameter(ParameterSetName='CsvPath', Mandatory=$true)][string]$CsvPath,

        # Column name for the disposition value of a record
        # Note: You can choose to use this option OR -CommonDispositionValue. You cannot use both
        [Parameter(Mandatory=$false)][string]$DispositionColumnName,

        # Disposition value when the same disposition is assigned to all records in the list.
        # Note: You can choose to use this option OR -DispositionColumnName. You cannot use both
        [Parameter(Mandatory=$false)][string]$CommonDispositionValue,

        # Single string, or array of strings which designate key(s). Used when a record needs to be updated, it is used to find the record to update in the contact database.
        # If omitted, all columns will make up the key
        [Parameter(Mandatory=$false)][string[]]$Key,

        <#
        Specifies how contact records should be updated when records are added to a dialing list.

        Options are:
            • UPDATE_ALL (Default) - Update disposition for all records that match the key
            • UPDATE_IF_SOLE_CRM_MATCH - Update disposition if only one record matches the key. Otherwise, request for update is denied.
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("UPDATE_ALL", "UPDATE_IF_SOLE_CRM_MATCH")]$DispositionsUpdateMode = "UPDATE_ALL",

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

        if ($PSBoundParameters.Keys -contains 'CommonDispositionValue' -and $PSBoundParameters.Keys -contains 'DispositionColumnName')
        {
            throw "You cannot use both -DispositionColumnName and -CommonDispositionValue. See help for examples."
            return
        }

        if ($PSBoundParameters.Keys -notcontains 'CommonDispositionValue' -and $PSBoundParameters.Keys -notcontains 'DispositionColumnName')
        {
            throw "You must use either -DispositionColumnName or -CommonDispositionValue. See help for examples.'"
            return
        }

        $dispositionsUpdateSettings = New-Object PSFive9Admin.dispositionsUpdateSettings

        $headers = $csv[0] -replace '"' -split ','

        if ($PSBoundParameters.Keys -contains 'DispositionColumnName')
        {
            if ($headers -cnotcontains $DispositionColumnName)
            {
                throw "Imported data does not contain a column with header '$DispositionColumnName'."
                return
            }

            $dispositionsUpdateSettings.updateToCommonDisposition = $false

        }
        elseif ($PSBoundParameters.Keys -contains 'CommonDispositionValue')
        {
            try
            {
                $dispFromFive9 = $DefaultFive9AdminClient.getDisposition($CommonDispositionValue)
            }
            catch
            {
                throw "Disposition '$CommonDispositionValue' does not exist in Five9. Please use a valid disposition."
            }

            $dispositionsUpdateSettings.updateToCommonDisposition = $true
            $dispositionsUpdateSettings.commonDispositionValue = $CommonDispositionValue
        }

        # verify that key(s) passed are present in $Inputobject
        foreach ($k in $Key)
        {
            if ($headers -notcontains $k)
            {
                throw "Specified key '$k' is not a property name found in data being imported."
                return
            }
        }
        
        # prepare "fieldMapping" per Five9's documentation
        $counter = 1
        foreach ($header in $headers)
        {
            if ($DispositionColumnName -eq $header)
            {
                if ($PSBoundParameters.Keys -contains 'DispositionColumnName')
                {
                    $dispositionsUpdateSettings.dispositionColumnNumber = $counter
                }

                continue
            }

            $isKey = $false
            if ($PSBoundParameters.Keys -notcontains 'Key' -or $Key -contains $header)
            {
                $isKey = $true
            }
            
            $dispositionsUpdateSettings.fieldsMapping += @{
                columnNumber = $counter
                fieldName = $header
                key = $isKey
            }

            $counter++
        }

        $csvData = ($csv | select -Skip 1) | Out-String

        $dispositionsUpdateSettings.dispositionsUpdateMode = $DispositionsUpdateMode
        $dispositionsUpdateSettings.dispositionsUpdateModeSpecified = $true
    

        if ($PSBoundParameters.Keys -contains "FailOnFieldParseError")
        {
            $dispositionsUpdateSettings.failOnFieldParseErrorSpecified = $true
            $dispositionsUpdateSettings.failOnFieldParseError = $FailOnFieldParseError
        }

        if ($PSBoundParameters.Keys -contains "ReportEmail")
        {
            $dispositionsUpdateSettings.reportEmail = $ReportEmail
        }
    
        Write-Verbose "$($MyInvocation.MyCommand.Name): Updating dispositions on campaign '$CampaignName'." 

        $response = $global:DefaultFive9AdminClient.updateDispositionsCsv($CampaignName, $dispositionsUpdateSettings, $csvData)
        
        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
