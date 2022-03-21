function Set-Five9CampaignProfileFilter
{
    <#
    .SYNOPSIS
    
        Function used to return campaign profile filters and order by fields assoicated with one campaign profile

    .EXAMPLE

        Set-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads' -GroupingType: Custom -Expression '1 AND (2 OR 3)'

        # Set custom grouping type using a custom expression

    .EXAMPLE
        `
        $newFilter = New-Object campaignProfileFilter
        $newFilter.leftValue = 'zip'
        $newFilter.compareOperator = 'Equals'
        $newFilter.rightValue = '94583'

        Set-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads' -AddFilterObject $newFilter

        # Add a new campaign profile filter

    .EXAMPLE

        Set-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads' -RemoveFilterId 1

        # Remove the first campaign profile filter

    .EXAMPLE
        `
        $orderByObj = New-Object PSFive9Admin.orderByField
        $orderByObj.rank = 1
        $orderByObj.fieldName = 'zip'
        $orderByObj.descending = $false

        Set-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads' -AddOrderByObject $orderByObj

        # Adds new order by field to campaign profile

    .EXAMPLE

        Set-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads' -RemoveOrderByFieldName 'first_name'

        # Adds new order by field to campaign profile

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of existing campaign profile
        [Parameter(Mandatory=$true, Position=0)][string]$ProfileName,

        <#
        Contains the types of filters that you can apply before a record can be called
        If omitted, the existing value will be used

        Options are:
            • All - All the conditions must be met
            • Any - Any of the conditions must be met
            • Custom - Custom relationship defined by using parameter -Expression
        #>
        [Parameter(Mandatory=$false)][ValidateSet('All', 'Any', 'Custom')][string]$GroupingType,

        <#
        Expression for the group of filters if -GroupingType is 'Custom'
        If omitted, the existing value will be used
        The supported operators are AND, OR, NOT.
        Example: (1 AND 2 AND 3) OR (4 AND 5 AND 6 AND 7)
        #>
        [Parameter(Mandatory=$false)][string]$Expression,

        <# 
        One or more campaignProfileFilter objects to be added as filters

        Example:
            $newFilter = New-Object campaignProfileFilter
            $newFilter.leftValue = 'zip'
            $newFilter.compareOperator = 'Equals'
            $newFilter.rightValue = '94583'

            Set-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads' -AddFilterObject $newFilter

            Note: Id is omitted from $newFilter. If passed, it will be ignored
                  If multiple new filters are added, they will be added in the order they are passed

            Note: For more information on allowed compareOperator values, see Five9 documentation:
                  https://webapps.five9.com/assets/files/for_customers/documentation/apis/config-webservices-api-reference-guide.pdf#page=65
        #>
        [Parameter(Mandatory=$false)][campaignProfileFilter[]]$AddFilterObject,


        # One or more Filter Ids to be removed. For example, the first filter is Id 1, etc.
        [Parameter(Mandatory=$false)][ValidateRange(1,999)][int[]]$RemoveFilterId,


        <# 
        One or more orderByField objects to be added as orderBy fields

         Example:
            $orderByObj = New-Object PSFive9Admin.orderByField
            $orderByObj.rank = 1
            $orderByObj.fieldName = 'zip'
            $orderByObj.descending = $false

            Set-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads' -AddOrderByObject $orderByObj

        #>
        [Parameter(Mandatory=$false)][object[]]$AddOrderByObject,


        # One or more Order By field names to be removed from Order By list
        [Parameter(Mandatory=$false)][string[]]$RemoveOrderByFieldName

    )

    try
    {

        Test-Five9Connection -ErrorAction: Stop
       
        $existingProfileFilters = Get-Five9CampaignProfileFilter -ProfileName $ProfileName -ErrorAction Stop -Verbose: $false

        $groupingObj = New-Object PSFive9Admin.crmCriteriaGrouping
        $addFilterList = @()
        $removeFilterList = @()


        if ($PSBoundParameters.Keys -contains 'GroupingType')
        {
            $groupingObj.type = $GroupingType
            $groupingObj.typeSpecified = $true
        }
        else
        {
            $groupingObj.type = $existingProfileFilters.groupingType
            $groupingObj.typeSpecified = $true
        }

        if ($groupingObj.type -eq 'Custom')
        {
            if ($PSBoundParameters.Keys -contains 'Expression')
            {
                $groupingObj.expression = $Expression
            }
            else
            {
                if ($existingProfileFilters.expression.Length -lt 1)
                {
                    throw "When -GroupingType is set to 'Custom', parameter -Expression must be used. Example: 'Set-Five9CampaignProfileFilter -ProfileName '$ProfileName' -GroupingType 'Custom' -Expression '1 AND (2 OR 3)'"
                    return
                }

                $groupingObj.expression = $existingProfileFilters.expression
            }
        }



        if ($PSBoundParameters.Keys -contains 'AddFilterObject')
        {
            foreach ($newFil in $AddFilterObject)
            {
                if ($newFil.leftValue.Length -lt 1 -or $newFil.compareOperator.Length -lt 1 -or $newFil.rightValue.Length -lt 1)
                {
                    throw "Error processing new filter with null values -- leftValue: '$($newFil.leftValue)', compareOperator: '$($newFil.compareOperator)', rightValue: '$($newFil.rightValue)'"
                    return
                }

                $addFilterCriterion = New-Object PSFive9Admin.campaignFilterCriterion
                $addFilterCriterion.leftValue = $newFil.leftValue
                $addFilterCriterion.compareOperator = $newFil.compareOperator
                $addFilterCriterion.compareOperatorSpecified = $true
                $addFilterCriterion.rightValue = $newFil.rightValue

                $addFilterList += $addFilterCriterion

            }
        }

        if ($PSBoundParameters.Keys -contains 'RemoveFilterId')
        {
            foreach ($filterId in $RemoveFilterId)
            {
                $filterToRemove = $null
                $filterToRemove = $existingProfileFilters.filters | ? {$_.id -eq $filterId}

                if (!$filterToRemove)
                {
                    throw "Campaign Profile '$ProfileName' does not contain FilterId '$filterId'. Check existing filters using: Get-Five9CampaignProfileFilter -ProfileName '$ProfileName'"
                    return
                }

                $removeFilterCriterion = New-Object PSFive9Admin.campaignFilterCriterion
                $removeFilterCriterion.compareOperator = $filterToRemove.compareOperator
                $removeFilterCriterion.compareOperatorSpecified = $true
                $removeFilterCriterion.leftValue = $filterToRemove.leftValue
                $removeFilterCriterion.rightValue = $filterToRemove.rightValue

                $removeFilterList += $removeFilterCriterion
            }

        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying campaign profile filter settings for: '$ProfileName'." 
        $global:DefaultFive9AdminClient.modifyCampaignProfileCrmCriteria($ProfileName, $groupingObj, $addFilterList, $removeFilterList)
        

        if ($PSBoundParameters.Keys -contains 'AddOrderByObject' -or $PSBoundParameters.Keys -contains 'RemoveOrderByFieldName')
        {
            $addOrderByList = @()
            $removeOrderByList = @()

            if ($PSBoundParameters.Keys -contains 'AddOrderByObject')
            {
                foreach ($newOrd in $AddOrderByObject)
                {
                    if ($newOrd.rank.Length -lt 1 -or $newOrd.fieldName.Length -lt 1 -or $newOrd.descending.Length -lt 1)
                    {
                        throw "Error processing new orderBy with null values -- rank: '$($newOrd.rank)', fieldName: '$($newOrd.fieldName)', descending: '$($newOrd.descending)'"
                        return
                    }

                    $addFilterField = New-Object PSFive9Admin.orderByField
                    $addFilterField.rank = $newOrd.rank
                    $addFilterField.rankSpecified = $true
                    $addFilterField.fieldName = $newOrd.fieldName
                    $addFilterField.descending = $newOrd.descending
                    $addFilterField.descendingSpecified = $true

                    $addOrderByList += $addFilterField

                }
            }

            if ($PSBoundParameters.Keys -contains 'RemoveOrderByFieldName')
            {
                foreach ($orderByName in $RemoveOrderByFieldName)
                {
                    $orderByToRemove = $null
                    $orderByToRemove = $existingProfileFilters.orderByFields | ? {$_.fieldName -eq $orderByName}

                    if (!$orderByToRemove)
                    {
                        throw "Campaign Profile '$ProfileName' does not contain Order By field '$orderByName'. Check existing Order By fields using: Get-Five9CampaignProfileFilter -ProfileName '$ProfileName'"
                        return
                    }

                    $removeOrderByList += $orderByName

                }

            }

            if ($addOrderByList.Count -gt 0 -or $removeOrderByList.Count -gt 0)
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying campaign profile Order By settings for: '$ProfileName'." 
                $global:DefaultFive9AdminClient.modifyCampaignProfileFilterOrder($ProfileName, $addOrderByList, $removeOrderByList)
            }
        }

        

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
