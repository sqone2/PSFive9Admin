<#
.SYNOPSIS
    
    Function used to create a new contact field
 
.PARAMETER Name

    Name of new contact field

.PARAMETER Type

    Type of data stored in this field
    Options are:
        • STRING (Default) - Letters and numbers
        • NUMBER - Numbers only
        • DATE - Date only
        • TIME - Time only
        • DATE_TIME - Date and time
        • CURRENCY - Currency
        • BOOLEAN - True or false
        • PERCENT - Percentage
        • EMAIL - Email address
        • URL - URL
        • PHONE - Phone number
        • TIME_PERIOD - Time interval (Duration)

.PARAMETER MapTo

    Map of the system information into the field. The field is updated when a disposition is set
    Options are:
        • None (Default)
        • LastAgent - Name of last logged-in agent.
        • LastDisposition - Name of last disposition assigned to a call.
        • LastSystemDisposition - Name of last system disposition assigned to a call.
        • LastAgentDisposition - Name of last disposition assigned by an agent to a call.
        • LastDispositionDateTime - Date and time of last disposition assigned to a call.
        • LastSystemDispositionDateTime - Date and time of last system disposition assigned to a call.
        • LastAgentDispositionDateTime - Date and time of last disposition assigned by an agent to a call.
        • LastAttemptedNumber - Last number attempted by the dialer or by an agent.
        • LastAttemptedNumberN1N2N3 - Index of the last dialed phone number in the record: number1, number2 or number3

        Note: a domain can only contain one contact field for each mapping

.PARAMETER DisplayAs

    Display options for the data in the Agent desktop
    Options are:
        • Short (Default) - Half line
        • Long - Full line
        • Invisible - Not represented

.PARAMETER Required

    Whether the field must contain a value

.PARAMETER PredefinedList

    Single string, or array of multiple strings which are the only possible values for this field to be set to

.PARAMETER CanSelectMultiple

    Whether multiple values from PredefinedList can be selected as value

.PARAMETER MinValue

    Minimum value

.PARAMETER MaxValue

    Maximum value

.PARAMETER Regexp
    
    Regular expression that field value must match

.PARAMETER DigitsBeforeDecimal

    Digits before decimal point

.PARAMETER DigitsAfterDecimal

    Digits after decimal point

.PARAMETER TimeFormat

    Time format string. i.e. yyyy-MM-dd

.PARAMETER DateFormat

    Time format string. i.e. HH:mm:ss.SSS

.PARAMETER TimePeriodFormat

    Time format string. i.e. hh:mm:ss.SSS

.PARAMETER CurrencyType

    Type of currency
    Options are:
        • Dollar
        • Euro
        • Pound


.EXAMPLE
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9ContactField -Five9AdminClient $adminClient -Name 'hair_color'

    # Creates new contact field using default values

.EXAMPLE

    $preDefinedList = @('Brown', 'Blue', 'Green')
    New-Five9ContactField -Five9AdminClient $adminClient -Name 'eye_color' -PredefinedList $preDefinedList -CanSelectMultiple: $false

    # Creates new contact field including a list of predefined items

.EXAMPLE

    New-Five9ContactField -Five9AdminClient $adminClient -Name 'date_of_hire' -DateFormat -Type: DATE -DateFormat 'yyyy-MM-dd' -TimeFormat 'HH:mm:ss.SSS'

    # Creates new contact field as date type

#>
function New-Five9ContactField
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][ValidateSet('STRING','NUMBER','DATE','TIME','DATE_TIME','CURRENCY','BOOLEAN','PERCENT','EMAIL','URL','PHONE','TIME_PERIOD')][string]$Type = 'STRING',
        [Parameter(Mandatory=$false)][ValidateSet('None','LastDisposition','LastSystemDisposition','LastAgentDisposition','LastDispositionDateTime','LastSystemDispositionDateTime','LastAgentDispositionDateTime','LastAttemptedNumber','LastAttemptedNumberN1N2N3','LastCampaign','AttemptsForLastCampaign','LastList','CreatedDateTime','LastModifiedDateTime')][string]$MapTo = 'None',
        [Parameter(Mandatory=$false)][ValidateSet('Short', 'Long', 'Invisible')][string]$DisplayAs = 'Short',

        # Restrictions
        [Parameter(Mandatory=$false)][bool]$Required,
        [Parameter(Mandatory=$false)][string[]]$PredefinedList, #Set
        [Parameter(Mandatory=$false)][bool]$CanSelectMultiple, #Multiset
        [Parameter(Mandatory=$false)][string]$MinValue,
        [Parameter(Mandatory=$false)][string]$MaxValue,
        [Parameter(Mandatory=$false)][string]$Regexp,
        [Parameter(Mandatory=$false)][int]$DigitsBeforeDecimal, #Scale
        [Parameter(Mandatory=$false)][int]$DigitsAfterDecimal, #Precision
        [Parameter(Mandatory=$false)][string]$TimeFormat,
        [Parameter(Mandatory=$false)][string]$DateFormat,
        [Parameter(Mandatory=$false)][string]$TimePeriodFormat,
        [Parameter(Mandatory=$false)][ValidateSet('Dollar', 'Pound', 'Euro')][string]$CurrencyType
    )

    $contactField = New-Object PSFive9Admin.contactField

    $contactField.name = $Name

    $contactField.type = $Type
    $contactField.typeSpecified = $true

    $contactField.mapTo = $MapTo
    $contactField.mapToSpecified = $true

    $contactField.displayAs = $DisplayAs
    $contactField.displayAsSpecified = $true

    if ($Required -eq $true)
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'Required'
        $restriction.typeSpecified = $true
        $restriction.value = $true

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'PredefinedList')
    {
        foreach ($item in $PredefinedList)
        {
            $restriction = New-Object PSFive9Admin.contactFieldRestriction
            $restriction.typeSpecified = $true
            $restriction.value = $item

            if ($CanSelectMultiple -eq $true)
            {
                $restriction.type = 'Multiset'
            }
            else
            {
                $restriction.type = 'Set'
            }

            $contactField.restrictions += $restriction
        }
    }

    if ($PSBoundParameters.Keys -contains 'MinValue')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'MinValue'
        $restriction.typeSpecified = $true
        $restriction.value = $MinValue

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'MaxValue')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'MaxValue'
        $restriction.typeSpecified = $true
        $restriction.value = $MaxValue

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'Regexp')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'Regexp'
        $restriction.typeSpecified = $true
        $restriction.value = $Regexp

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'DigitsBeforeDecimal')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'Scale'
        $restriction.typeSpecified = $true
        $restriction.value = $DigitsBeforeDecimal

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'DigitsAfterDecimal')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'Precision'
        $restriction.typeSpecified = $true
        $restriction.value = $DigitsAfterDecimal

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'TimeFormat')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'TimeFormat'
        $restriction.typeSpecified = $true
        $restriction.value = $TimeFormat

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'DateFormat')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'DateFormat'
        $restriction.typeSpecified = $true
        $restriction.value = $DateFormat

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'TimePeriodFormat')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        $restriction.type = 'TimePeriodFormat'
        $restriction.typeSpecified = $true
        $restriction.value = $TimePeriodFormat

        $contactField.restrictions += $restriction
    }

    if ($PSBoundParameters.Keys -contains 'CurrencyType')
    {
        $restriction = New-Object PSFive9Admin.contactFieldRestriction
        
        $restriction.type = 'CurrencyType'
        $restriction.typeSpecified = $true
       
        if ($CurrencyType -eq 'Dollar')
        {
            $restriction.value = '$'
        }
        elseif ($CurrencyType -eq 'Pound')
        {
            $restriction.value = '£'
        }
        elseif ($CurrencyType -eq 'Euro')
        {
            $restriction.value = '€'
        }

        $contactField.restrictions += $restriction
    }

 
    return $Five9AdminClient.createContactField($contactField)

}


