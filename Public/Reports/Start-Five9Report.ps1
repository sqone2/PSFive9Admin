function Start-Five9Report
{
    <#
    .SYNOPSIS
    
        Function used to run an existing Five9 report

    .EXAMPLE
    
        Start-Five9Report -FolderName "Call Log Reports" -ReportName 'Call Log'

        # Starts Call Log report within the Call Log Reports folder.
        # Function returns an identifier which can be used with Get-Five9ReportResult

    .EXAMPLE
    
        $id = Start-Five9Report -FolderName "Call Log Reports" -ReportName 'Call Log'
        $result = Get-Five9ReportResult -Identifier $id

        # Starts the Call Log report and using the returned identifier, gets the data from the report using Get-Five9ReportResult

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Folder where report is located (case sensitive). i.e. "Call Log Reports"
        [Parameter(Mandatory=$true, Position=0)][string]$FolderName,

        # Report Name (case sensitive). i.e. "Call Log"
        [Parameter(Mandatory=$true, Position=1)][string]$ReportName,

        # Start of the reporting period with the time zone. i.e. 2019-04-23T21:00:00.000-07:00
        # If parameter is omitted, start date will be set to 7 days ago
        [Parameter(Mandatory=$false)][datetime]$StartDateTime = ((Get-Date).AddDays(-7)),

        # End of the reporting period with the time zone. i.e. 2019-05-23T21:00:00.000-07:00
        # If parameter is omitted, the current date time will be used.
        [Parameter(Mandatory=$false)][datetime]$EndDateTime = (Get-Date)
    )

    try
    {

        Test-Five9Connection -ErrorAction: Stop


        $customReportCriteria = New-Object PSFive9Admin.customReportCriteria

        $customReportCriteria.time = New-Object PSFive9Admin.reportTimeCriteria
        $customReportCriteria.time.start = $StartDateTime
        $customReportCriteria.time.startSpecified = $true
        $customReportCriteria.time.end = $EndDateTime
        $customReportCriteria.time.endSpecified = $true


        <# report is better filtered in the reporting GUI

        $reportObject = New-Object PSFive9Admin.reportObjectList
        $reportObject.objectNames = 'Inbound-New'
        $reportObject.objectType = 'Campaign'
        $reportObject.objectTypeSpecified = $true
        $customReportCriteria.reportObjects += $reportObject

        #>

        Write-Verbose "$($MyInvocation.MyCommand.Name): Starting report '$FolderName\$ReportName'" 

        $id = $global:DefaultFive9AdminClient.runReport($FolderName, $ReportName, $customReportCriteria)

        return $id

    }
    catch
    {
        throw $_
    }
}
