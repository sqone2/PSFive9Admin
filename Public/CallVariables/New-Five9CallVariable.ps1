<#
.SYNOPSIS
    
    Function used to modify existing call variable

.PARAMETER Name

    Name of existing call variable

.PARAMETER Group

    Group name of existing call variable

.PARAMETER Description

    Description for new call variable

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

.PARAMETER ApplyToAllDispositions

    If set to $true, variable will be set for all dispositions

.PARAMETER Dispositions

    If -ApplyToAllDispositions is $false, this parameter lists the names of the dispositions for which to set this variable

.PARAMETER Reporting

    Whether to add the values to reports


.PARAMETER DefaultValue

    Optional value that may be assigned to a call variable. For example, a boolean's default value could be set to "True" or "False"


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

    Set-Five9CallVariable -Name "MiddleName" -Group "CustomerVars" -ApplyToAllDispositions $true -Reporting $true

    # Modifies existing call variable named "MiddleName" within the "CustomerVars" call variable group
    
#>

function New-Five9CallVariable
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Group,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][ValidateSet('STRING', 'NUMBER', 'DATE', 'TIME', 'DATE_TIME', 'CURRENCY', 'BOOLEAN', 'PERCENT', 'EMAIL', 'URL', 'PHONE', 'TIME_PERIOD')][string]$Type = "STRING",
        [Parameter(Mandatory=$false)][bool]$ApplyToAllDispositions = $false,
        [Parameter(Mandatory=$false)][string[]]$Dispositions,
        [Parameter(Mandatory=$false)][bool]$Reporting,
        [Parameter(Mandatory=$false)][string]$DefaultValue,
        [Parameter(Mandatory=$false)][bool]$SensitiveData,

        # Restrictions
        [Parameter(Mandatory=$false)][bool]$Required,
        [Parameter(Mandatory=$false)][string[]]$PredefinedList, #Set
        [Parameter(Mandatory=$false)][bool]$CanSelectMultiple, #Multiset
        [Parameter(Mandatory=$false)][string]$MinValue,
        [Parameter(Mandatory=$false)][string]$MaxValue,
        [Parameter(Mandatory=$false)][string]$Regexp,
        [Parameter(Mandatory=$false)][int]$DigitsBeforeDecimal, #Scale
        [Parameter(Mandatory=$false)][int]$DigitsAfterDecimal, #Precision
        [Parameter(Mandatory=$false)][ValidateSet('HH:mm:ss.SSS', 'HH:mm:ss', 'HH:mm', 'hh:mm a', 'HH', 'hh a', 'H:mm', 'h:mm a')][string]$TimeFormat,
        [Parameter(Mandatory=$false)][ValidateSet('yyyy-MM-dd', 'MM/dd/yyyy', 'MM-dd-yyyy', 'MM-dd-yy', 'MMM dd', 'yyyy', 'dd MMM', 'dd-MM', 'MM-dd')][string]$DateFormat,
        [Parameter(Mandatory=$false)][ValidateSet('hh:mm:ss.SSS', 'hh:mm:ss', 'hh:mm', 'hh', 'mm:ss.SSS', 'mm:ss', 'mm', 'ss.SSS', 'ss', 'SSS')][string]$TimePeriodFormat,
        [Parameter(Mandatory=$false)][ValidateSet('Dollar', 'Pound', 'Euro')][string]$CurrencyType
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop


        $callVariable = New-Object PSFive9Admin.callVariable

        $callVariable.name = $Name
        $callVariable.group = $Group

        if ($PSBoundParameters.Keys -contains "Description")
        {
            $callVariable.description = $Description
        }

        $callVariable.type = $Type
        $callVariable.typeSpecified = $true

        # param is mandatory
        $callVariable.applyToAllDispositions = $ApplyToAllDispositions
        $callVariable.applyToAllDispositionsSpecified = $true
    
        if ($ApplyToAllDispositions -eq $false)
        {
            $callVariable.dispositions = $Dispositions
        }

        if ($PSBoundParameters.Keys -contains "Reporting")
        {
            $callVariable.reporting = $Reporting
            $callVariable.reportingSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "SensitiveData")
        {
            $callVariable.sensitiveData = $SensitiveData
            $callVariable.sensitiveDataSpecified = $True
        }

        if ($Required -eq $true)
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'Required'
            $restriction.typeSpecified = $true
            $restriction.value = $true

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'PredefinedList')
        {
            foreach ($item in $PredefinedList)
            {
                $restriction = New-Object PSFive9Admin.callVariableRestriction
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

                $callVariable.restrictions += $restriction
            }

        }
        else
        {
            # unable to set defaultvalue when specifying a predefined list. seems to be a bug with the API
            if ($PSBoundParameters.Keys -contains "DefaultValue")
            {
                $callVariable.defaultValue = $DefaultValue
            }
        }

        if ($PSBoundParameters.Keys -contains 'MinValue')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'MinValue'
            $restriction.typeSpecified = $true
            $restriction.value = $MinValue

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'MaxValue')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'MaxValue'
            $restriction.typeSpecified = $true
            $restriction.value = $MaxValue

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'Regexp')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'Regexp'
            $restriction.typeSpecified = $true
            $restriction.value = $Regexp

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'DigitsBeforeDecimal')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'Scale'
            $restriction.typeSpecified = $true
            $restriction.value = $DigitsBeforeDecimal

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'DigitsAfterDecimal')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'Precision'
            $restriction.typeSpecified = $true
            $restriction.value = $DigitsAfterDecimal

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'TimeFormat')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'TimeFormat'
            $restriction.typeSpecified = $true
            $restriction.value = $TimeFormat

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'DateFormat')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'DateFormat'
            $restriction.typeSpecified = $true
            $restriction.value = $DateFormat

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'TimePeriodFormat')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'TimePeriodFormat'
            $restriction.typeSpecified = $true
            $restriction.value = $TimePeriodFormat

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'CurrencyType')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
        
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

            $callVariable.restrictions += $restriction
        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying call variable '$Name'." 
        $response = $global:DefaultFive9AdminClient.createCallVariable($callVariable)
        return $response

    }
    catch
    {
        Write-Error $_
    }
}



