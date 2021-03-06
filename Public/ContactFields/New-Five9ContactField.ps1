function New-Five9ContactField
{
    <#
    .SYNOPSIS
    
        Function used to create a new contact field

    .EXAMPLE
        New-Five9ContactField -Name 'hair_color'

        # Creates new contact field using default values

    .EXAMPLE

        $preDefinedList = @('Brown', 'Blue', 'Green')
        New-Five9ContactField -Name 'eye_color' -PredefinedList $preDefinedList -CanSelectMultiple: $false

        # Creates new contact field including a list of predefined items

    .EXAMPLE

        New-Five9ContactField -Name 'date_of_hire' -DateFormat -Type: DATE_TIME -DateFormat 'yyyy-MM-dd' -TimeFormat 'HH:mm:ss.SSS'

        # Creates new contact field as date type

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of new contact field
        [Parameter(Mandatory=$true)][string]$Name,
        
        <#
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
        #>
        [Parameter(Mandatory=$false)][ValidateSet('STRING','NUMBER','DATE','TIME','DATE_TIME','CURRENCY','BOOLEAN','PERCENT','EMAIL','URL','PHONE','TIME_PERIOD')][string]$Type = 'STRING',
        
        <#
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
        #>
        [Parameter(Mandatory=$false)][ValidateSet('None','LastDisposition','LastSystemDisposition','LastAgentDisposition','LastDispositionDateTime','LastSystemDispositionDateTime','LastAgentDispositionDateTime','LastAttemptedNumber','LastAttemptedNumberN1N2N3','LastCampaign','AttemptsForLastCampaign','LastList','CreatedDateTime','LastModifiedDateTime')][string]$MapTo = 'None',
        
        <#
        Display options for the data in the Agent desktop

        Options are:
            • Short (Default) - Half line
            • Long - Full line
            • Invisible - Not represented
        #>
        [Parameter(Mandatory=$false)][ValidateSet('Short', 'Long', 'Invisible')][string]$DisplayAs = 'Short',

        # Whether the field must contain a value
        [Parameter(Mandatory=$false)][bool]$Required,
        
        # Single string, or array of multiple strings which are the only possible values for this field to be set to
        [Parameter(Mandatory=$false)][string[]]$PredefinedList,
        
        # Whether multiple values from PredefinedList can be selected as value
        [Parameter(Mandatory=$false)][bool]$CanSelectMultiple,
        
        # Minimum value
        # Note: When Type is set to TIME, value must be UTC time
        [Parameter(Mandatory=$false)][string]$MinValue,

        # Maximum value
        # Note: When Type is set to TIME, value must be UTC time
        [Parameter(Mandatory=$false)][string]$MaxValue,

        # Regular expression that field value must match
        [Parameter(Mandatory=$false)][string]$Regexp,

        # Digits before decimal point
        [Parameter(Mandatory=$false)][ValidateRange(1,16)][int]$DigitsBeforeDecimal,

        # Digits after decimal point
        [Parameter(Mandatory=$false)][ValidateRange(0,11)][int]$DigitsAfterDecimal,

        # Time format string. i.e. yyyy-MM-dd
        [Parameter(Mandatory=$false)][ValidateSet('HH:mm:ss.SSS', 'HH:mm:ss', 'HH:mm', 'hh:mm a', 'HH', 'hh a', 'H:mm', 'h:mm a')][string]$TimeFormat,

        # Time format string. i.e. HH:mm:ss.SSS
        [Parameter(Mandatory=$false)][ValidateSet('yyyy-MM-dd', 'MM/dd/yyyy', 'MM-dd-yyyy', 'MM-dd-yy', 'MMM dd', 'yyyy', 'dd MMM', 'dd-MM', 'MM-dd')][string]$DateFormat,

        # Time format string. i.e. hh:mm:ss.SSS
        [Parameter(Mandatory=$false)][ValidateSet('hh:mm:ss.SSS', 'hh:mm:ss', 'hh:mm', 'hh', 'mm:ss.SSS', 'mm:ss', 'mm', 'ss.SSS', 'ss', 'SSS')][string]$TimePeriodFormat,

        <#
        Type of currency

        Options are:
            • Dollar
            • Euro
            • Pound
        #>
        [Parameter(Mandatory=$false)][ValidateSet('Dollar', 'Pound', 'Euro')][string]$CurrencyType
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

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
            $restriction.type = 'Precision'
            $restriction.typeSpecified = $true
            $restriction.value = ($DigitsBeforeDecimal + $DigitsAfterDecimal)

            $contactField.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'DigitsAfterDecimal')
        {
            $restriction = New-Object PSFive9Admin.contactFieldRestriction
            $restriction.type = 'Scale'
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

        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new contact field '$Name'." 
        return $global:DefaultFive9AdminClient.createContactField($contactField)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}


