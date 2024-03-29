function New-Five9CallVariable
{
    <#
    .SYNOPSIS
    
        Function used to modify existing call variable

    .EXAMPLE

        Set-Five9CallVariable -VariableName "MiddleName" -GroupName "CustomerVars" -ApplyToAllDispositions $true -Reporting $true

        # Modifies existing call variable named "MiddleName" within the "CustomerVars" call variable group
    
    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of existing call variable
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$VariableName,

        # Group name of existing call variable
        [Parameter(Mandatory=$true, Position=1)][Alias('Group')][string]$GroupName,

        # Description for new call variable
        [Parameter(Mandatory=$false)][string]$Description,

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
        [Parameter(Mandatory=$false)][ValidateSet('STRING', 'NUMBER', 'DATE', 'TIME', 'DATE_TIME', 'CURRENCY', 'BOOLEAN', 'PERCENT', 'EMAIL', 'URL', 'PHONE', 'TIME_PERIOD')][string]$Type = "STRING",

        # If set to $true, variable will be set for all dispositions
        [Parameter(Mandatory=$false)][bool]$ApplyToAllDispositions = $false,

        # If -ApplyToAllDispositions is $false, this parameter lists the names of the dispositions for which to set this variable
        [Parameter(Mandatory=$false)][string[]]$Dispositions,

        # Whether to add the values to reports
        [Parameter(Mandatory=$false)][bool]$Reporting,

        # Default initial value assigned to call variable
        [Parameter(Mandatory=$false)][string]$DefaultValue,

        # Whether the variable contains personal data that identifies the customer
        [Parameter(Mandatory=$false)][bool]$SensitiveData,

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


        $callVariable = New-Object PSFive9Admin.callVariable

        $callVariable.name = $VariableName
        $callVariable.group = $GroupName

        if ($PSBoundParameters.Keys -contains "Description")
        {
            $callVariable.description = $Description
        }

        $callVariable.type = $Type
        $callVariable.typeSpecified = $true

        # param is mandatory
        $callVariable.applyToAllDispositions = $ApplyToAllDispositions
        $callVariable.applyToAllDispositionsSpecified = $true
    
        if ($ApplyToAllDispositions -eq $true)
        {
            $callVariable.dispositions = ($global:DefaultFive9AdminClient.getDispositions('.*')).name
        }
        else 
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
            $restriction.type = 'Precision'
            $restriction.typeSpecified = $true
            $restriction.value = ($DigitsBeforeDecimal + $DigitsAfterDecimal)

            $callVariable.restrictions += $restriction
        }

        if ($PSBoundParameters.Keys -contains 'DigitsAfterDecimal')
        {
            $restriction = New-Object PSFive9Admin.callVariableRestriction
            $restriction.type = 'Scale'
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


        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new call variable '$VariableName' in group '$GroupName'." 
        $response = $global:DefaultFive9AdminClient.createCallVariable($callVariable)
        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



