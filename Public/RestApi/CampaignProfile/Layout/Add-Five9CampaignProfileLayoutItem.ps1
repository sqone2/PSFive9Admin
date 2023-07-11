function Add-Five9CampaignProfileLayoutItem
{
    <#
    .SYNOPSIS

        Function for adding a CRM or CAV to a campaign profile layout

    .EXAMPLE

        Add-Five9CampaignProfileLayoutItem -ProfileName 'Inbound-Profile' -FieldType: CAV -FieldName 'Salesforce.CaseSubject' -FieldTitle 'Subject'
        # Adds a CAV to campaign profile named 'Inboune-Profile'


    .EXAMPLE

        Add-Five9CampaignProfileLayoutItem -ProfileName 'Inbound-Profile' -FieldType: CRM -FieldName 'Customer.first_name' -FieldTitle 'First Name' -LineNumber 6 -Editable $false -Width 75

        # Adds a contact field to campaign profile including other parameters

    #>

    [CmdletBinding(DefaultParametersetName = 'Name', PositionalBinding = $false)]
    param
    (
        # Name of campaign profile to add layout item to
        [Parameter(ParameterSetName = 'Name', Mandatory = $true)][string]$ProfileName,

        # Id of campaign profile to add layout item to
        [Parameter(ParameterSetName = 'Id', Mandatory = $true)][string]$ProfileId,

        <#
        Field type

        Options are:
            • CRM (Contact field)
            • CAV (Call Attached Variable)
        #>
        [Parameter(Mandatory = $true)][ValidateSet('CAV', 'CRM')][string]$FieldType,


        <#
        Name of CRM or CAV field

        Format examples for passing Name:
            • If $FieldType is CRM: "Customer.first_name"
            • If $FieldType is CAV: "Reporting.AccountNum"
        #>
        [Parameter(ParameterSetName = 'Name', Mandatory = $true)][string]$FieldName,

        # Id of CRM or CAV field
        [Parameter(ParameterSetName = 'Id', Mandatory = $true)][string]$FieldId,


        # Display name of layout item
        # If omitted, value from $FieldName will be used
        [Parameter(Mandatory = $true)][string]$FieldTitle,

        # Order to be displayed in layout where 1 is the top of the list
        # If omitted, item will be placed at the end of the list
        [Parameter(Mandatory = $false)][ValidateRange(1, 999)][int]$LineNumber = 999,

        # Whether or not field can be edited by user
        # If omitted, value will be true
        [Parameter(Mandatory = $false)][bool]$Editable = $true,

        # Width to be shown in Agent Desktop Plus
        # If omitted, value will be 50
        [Parameter(Mandatory = $false)][ValidateRange(1, 100)][int]$Width = 50

    )

    try
    {
        Test-Five9Connection -ApiName 'REST' -ErrorAction: Stop

        if ($PSCmdlet.ParameterSetName -eq 'Name')
        {
            $campaignProfile = Get-Five9ObjectByName -Name $ProfileName -Type 'campaign-profiles'
            $ProfileId = $campaignProfile.id

            if ($FieldType -eq 'CRM')
            {
                $FieldName = $FieldName -replace '^Customer\.', ''

                $field = Get-Five9ObjectByName -Name $FieldName -Type 'contact-fields'
                $FieldId = $field.id
            }
            else
            {
                $field = Get-Five9ObjectByName -Name $FieldName -Type 'call-variables'
                $FieldId = $field.id
            }
        }

        if ($null -eq $FieldId -or $null -eq $ProfileId)
        {
            throw "Invalid ProfileId or FieldId"
        }

        # subtract 1 becasue API wants value zero index, but VCC shows the first item as 1
        $order = $LineNumber - 1


        $body = @{
            kind         = 'FIELD_VIEW'
            name         = $FieldTitle
            type         = $FieldType
            width        = $Width
            editable     = $Editable
            order        = $order
            relatedField = @{
                id = $FieldId
            }
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding new item $FieldName($FieldId) to Campaign Profile $ProfileName($ProfileId)."

        Invoke-Five9RestApi -Method "POST" -Path "campaign-profiles/$ProfileId/field-views" -Body $body -ErrorAction Stop


    }
    catch
    {
        $_ | Write-PSFive9AdminError
        $_ | Write-Error
    }
}


