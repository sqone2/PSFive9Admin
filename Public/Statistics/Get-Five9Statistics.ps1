function Get-Five9Statistics
{
    <#
    .SYNOPSIS
    
        Returns information about a specific type of data. This method contains all the data at
        once with the time stamp of the request, which can be used to request updates. Because
        the amount of data can be large, Five9 suggests that you use this method sparingly.
        Instead, to obtain regular updates, use Get-Five9StatisticsUpdate.

    .EXAMPLE
    
        Get-Five9Statistics -Type 'CampaignState'
    
        # Returns CampaignState statistics including all available columns
    
    .EXAMPLE
    
        Get-Five9Statistics -Type CampaignState -ColumnNames @('Campaign Name', 'State', 'State Since')
    
        # Returns CampaignState statistics for the specified columns

    .EXAMPLE
        
        $columns = Get-Five9ColumnNames -Type CampaignState
        Get-Five9Statistics -Type CampaignState -ColumnNames $columns
    
        # Equivalent to example one, but column names are retrieved manually

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        <#
        Statistic Type

        Options are:
            • AgentState
            • AgentStatistics
            • ACDStatus
            • CampaignState
            • OutboundCampaignManager
            • OutboundCampaignStatistics
            • InboundCampaignStatistics
            • AutodialCampaignStatistics
        #>
        [Parameter(Mandatory=$true)][ValidateSet('AgentState','AgentStatistics','ACDStatus','CampaignState','OutboundCampaignManager','OutboundCampaignStatistics','InboundCampaignStatistics','AutodialCampaignStatistics')][string]$Type,
        
        <#
        List of columns to return. If you omit this parameter, all columns are returned.
        To get a list of available columns for a given statistics type, see Get-Five9ColumnNames. 
        
        Note: 
            Be sure that your code can accommodate changes in the number of returned columns if you omit the parameter. 
            For example, the number of columns can change if you add custom dispositions to your domain or when Five9 makes software changes to the VCC. 
        #>
        [Parameter(Mandatory=$false)][string[]]$ColumnNames,
        
        # Whether to show only the current user’s queues.
        [Parameter(Mandatory=$false)][bool]$ShowOnlyMySkills = $false

    )

    try
    {
        Test-Five9StatsConnection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning '$Type' statistics." 

        $columnNameObj = New-Object PSFive9Admin.row
        $columnNameObj.values = $ColumnNames
        

        $response = $Five9StatisticsClient.getStatistics($Type, $true, $columnNameObj, $ShowOnlyMySkills, $true)

        $csv = @()

        $csv += $response.columns.values -join ','

        foreach ($row in $response.rows)
        {
            $csv += $row.values -join ','
        }

        $data = $csv | ConvertFrom-Csv

        $output = New-Object statisticOutput -Property @{
            type = $response.type
            timestamp = $response.timestamp
            data = $data
        }

        return $output
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
