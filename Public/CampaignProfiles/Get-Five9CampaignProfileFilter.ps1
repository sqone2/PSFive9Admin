function Get-Five9CampaignProfileFilter
{
    <#
    .SYNOPSIS
    
        Function used to return campaign profile filters and order by fields assoicated with one campaign profile

    .EXAMPLE

        Get-Five9CampaignProfileFilter -ProfileName 'Fresh-Leads'

        # Returns campaign profile filters and order by fields for campaign profile named 'Fresh-Leads'

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of existing campaign profile
        [Parameter(Mandatory=$true, Position=0)][string]$ProfileName
    )

    try
    {

        Test-Five9Connection -ErrorAction: Stop
       
        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning campaign profile filters for: '$ProfileName'." 
        $campaignProfileFilters = $global:DefaultFive9AdminClient.getCampaignProfileFilter($ProfileName)

        $customProfileObj = New-Object campaignProfileFilterConfig
        $customProfileObj.groupingType = $campaignProfileFilters.grouping.type
        $customProfileObj.expression = $campaignProfileFilters.grouping.expression
        $customProfileObj.orderByFields = $campaignProfileFilters.orderByFields | select rank,fieldName,descending | sort rank

        $idCounter = 1
        foreach ($filter in $campaignProfileFilters.crmCriteria)
        {
            $customFilterObj = $null
            $customFilterObj = New-Object campaignProfileFilter
            $customFilterObj.id = $idCounter
            $customFilterObj.leftValue = $filter.leftValue
            $customFilterObj.compareOperator = $filter.compareOperator
            $customFilterObj.rightValue = $filter.rightValue

            $customProfileObj.filters += $customFilterObj | select id,leftValue,compareOperator,rightValue

            $idCounter++
        }

        $customProfileObj.filters = $customProfileObj.filters | sort id

        return $customProfileObj

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
