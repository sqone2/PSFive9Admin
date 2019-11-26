<#
.SYNOPSIS
    
    Function used to get campaign(s) from Five9
 
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Type
 
    Campaign Type. Options are: INBOUND, OUTBOUND, AUTODIAL

.PARAMETER NamePattern
 
    Optional parameter. Returns only dispositions matching a given regex string

.NOTES

    Returning a single campaign also returns additional details that are NOT returned when multiple campaigns are returned.
   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9Campaign -Five9AdminClient $adminClient -Type OUTBOUND
    
    # Returns basic info on all outbound campaigns
    
.EXAMPLE
    
    Get-Five9Campaign -Five9AdminClient $adminClient -Type OUTBOUND -NamePattern 'MultiMedia' 

    # Returns basic and additional info for outbound campaign with name "MultiMedia"
    
 
#>
function New-Five9InboundCampaign
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$true)][ValidateSet('NOT_RUNNING', 'STARTING', 'RUNNING', 'STOPPING', 'RESETTING')][string]$State,

        [Parameter(Mandatory=$false)][ValidateSet('BASIC', 'ADVANCED')][string]$Mode = 'BASIC',
        [Parameter(Mandatory=$false)][string]$ProfileName,

        [Parameter(Mandatory=$false)][bool]$AutoRecord,
        [Parameter(Mandatory=$false)][bool]$RecordingNameAsSid,
        [Parameter(Mandatory=$false)][int]$MaxNumOfLines,

        [Parameter(Mandatory=$false)][string]$IvrScriptName,
        [Parameter(Mandatory=$false)][string]$CallWrapup,

        [Parameter(Mandatory=$false)][bool]$TrainingMode,

        [Parameter(Mandatory=$false)][bool]$UseFtp,
        [Parameter(Mandatory=$false)][string]$FtpHost,
        [Parameter(Mandatory=$false)][string]$FtpUser,
        [Parameter(Mandatory=$false)][string]$FtpPassword

    )

    $inboundCampaign = New-Object PSFive9Admin.inboundCampaign

    $inboundCampaign.type = "INBOUND"
    $inboundCampaign.typeSpecified = $true

    $inboundCampaign.name = $Name

    $inboundCampaign.state = $State
    $inboundCampaign.stateSpecified = $true

    $inboundCampaign.mode = $Mode
    $inboundCampaign.modeSpecified = $true

    if ($Type -eq 'ADVANCED')
    {
        # if type is advanced, must also provide a campaign profile name
        if ($PSBoundParameters -notcontains 'ProfileName')
        {
            throw "Campaign Type set as ""ADVANCED"", but no profile name was provided. Try again including the -ProfileName parameter."
            return
        }

        $inboundCampaign.profileName = $ProfileName

    }

    if ($PSBoundParameters.Keys -contains 'AutoRecord')
    {
        $inboundCampaign.autoRecord = $AutoRecord
        $inboundCampaign.autoRecordSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'RecordingNameAsSid')
    {
        $inboundCampaign.recordingNameAsSid = $RecordingNameAsSid
        $inboundCampaign.recordingNameAsSidSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'MaxNumOfLines')
    {
        $inboundCampaign.MaxNumOfLines = $MaxNumOfLines
        $inboundCampaign.maxNumOfLinesSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'asda')
    {
        $inboundCampaign.autoRecord = $AutoRecord
        $inboundCampaign.autoRecordSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'asd')
    {
        $inboundCampaign.autoRecord = $AutoRecord
        $inboundCampaign.autoRecordSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'adsas')
    {
        $inboundCampaign.autoRecord = $AutoRecord
        $inboundCampaign.autoRecordSpecified = $true
    }

    


    


}

