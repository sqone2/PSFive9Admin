function Get-Five9ContactRecord
{
    <#
    .SYNOPSIS
    
        Function used to return up to 1000 records from the contact database based on lookup criteria
 
    .NOTES

        Returns a maximum of 1000 records per call

    .EXAMPLE
    

        $hashtable = @{
            number1 = "615%"
        }

        Get-Five9ContactRecord -LookupCriteria $hashtable

        # Returns all records from the contact database where number1 starts with "615"

    .EXAMPLE

        $hashtable = @{
            first_name = "Steve"
            city = "Dallas"
        }

        Get-Five9ContactRecord -LookupCriteria $hashtable

        # Returns all records from the contact database where first_name equals "Steve" and city equals "Dallas"
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Hashtable containing the criteria used to find matching records in the contact database
        # Note: Hashtable values can use the % symbol for a wildcard. i.e. -LookupCriteria @{number1 = "925%"}
        [Parameter(Mandatory=$true)][hashtable]$LookupCriteria
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $crmLookupCriteria = New-Object PSFive9Admin.crmLookupCriteria

        foreach ($key in $LookupCriteria.Keys)
        {
            $criterion = New-Object PSFive9Admin.crmFieldCriterion

            $criterion.field = $key
            $criterion.value = $LookupCriteria[$key]

            $crmLookupCriteria.criteria += $criterion
        }

        $response = $global:DefaultFive9AdminClient.getContactRecords($crmLookupCriteria)


        if ($response.records.Count -lt 1)
        {
            # no records were found
            return
        }
        else
        {
            # convert response from Five9 API in pscustom objects
            $returnObjects = @()
            foreach ($record in $response.records)
            {
                $obj = New-Object psobject
                for ($i = 0; $i -lt $response.fields.Count; $i++)
                { 
                    $obj | Add-Member -MemberType: NoteProperty -Name $response.fields[$i] -Value $record.values[$i]
                }

                $returnObjects += $obj
            }

            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning $($returnObjects.Count) contact records matching LookupCritera." 
            return $returnObjects
        }

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}

