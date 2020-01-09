$here = $PSScriptRoot
$module = 'PSFive9Admin'



$cv_num
$cv_date
$cv_time
$cv_datetime
$cv_currency
$cv_bool
$cv_percent
$cv_email
$cv_url
$cv_phone
$cv_duration




Describe "AgentGroup" -Tag "AgentGroup" {

    Context ": Create call variable group" {

        It "Call variable group does not already exist" {
        
            $existingGroup = Get-Five9CallVariableGroup $module
        
            $existingGroup | Should -BeNullOrEmpty
        
        }

        It "Can create call variable group" {

            $createGroup = New-Five9CallVariableGroup -Name $module -Description $module
        }

        It "Call variable group was created correctly" {

            $cvGroup = Get-Five9CallVariableGroup $module

            $cvGroup | Should -Not -BeNullOrEmpty

            $cvGroup.name | Should -BeExactly $module
            $cvGroup.description | Should -BeExactly $module
        }

    }


    Context ": Create test call variables" {


        It "Create test call variable string_1" {

            $cv_string_1 = @{
                Group = $module
                Name = "string_1"
                Description = "string_1"
                Type = "STRING"

                Required = $true

                PredefinedList = @(
                    "string1"
                    "string2"
                    "string3"
                )

                DefaultValue = "string3"

                CanSelectMultiple = $true

                Reporting = $true
                ApplyToAllDispositions = $true
            }


            $create = New-Five9CallVariable @cv_string_1

        }

        It "Create test call variable string_2" {

            $cv_string_2 = @{
                Group = $module
                Name = "string_2"
                Description = "string_2"
                Type = "STRING"

                Required = $true

                Regexp = '^string[0-9]$'

                SensitiveData = $true

                #MinValue = "1"
                #MaxValue = "7" #Cannot use due to bug
            }

            $create = New-Five9CallVariable @cv_string_2

        }

        It "Create test call variable int_1" {

            $cv_int_1 = @{
                Group = $module
                Name = "int_1"
                Description = "int_1"
                Type = "NUMBER"
                Required = $true
                DigitsBeforeDecimal = 4
                DigitsAfterDecimal = 10
                MinValue = 1
                MaxValue = 100
                Reporting = $true
                ApplyToAllDispositions = $true
            }

            $create = New-Five9CallVariable @cv_int_1

        }

        It "Create test call variable date_1" {
            
            $cv_date_1 = @{
                Group = $module
                Name = "date_1"
                Description = "date_1"
                Type = "DATE"

                DateFormat = 'yyyy-MM-dd'
                DefaultValue = '2019-01-05'
                MinValue = '2018-01-16'
                MaxValue = '2020-05-01'
                Required = $true
                Reporting = $true
                ApplyToAllDispositions = $true
            }

            $create = New-Five9CallVariable @cv_date_1


        }


        It "Create test call variable time_1" {
            
            $cv_date_1 = @{
                Group = $module
                Name = "time_1"
                Description = "time_1"
                Type = "TIME"

                TimeFormat = 'HH:mm:ss.SSS'
                DefaultValue = '09:00:00.000'
                MinValue = '07:30:10.500'
                MaxValue = '23:30:10.250'
                Required = $true
                Reporting = $true
                ApplyToAllDispositions = $true
            }

            $create = New-Five9CallVariable @cv_date_1
        }

        It "Create test call variable datetime_1" {
            
            $cv_datetime_1= @{
                Group = $module
                Name = "datetime_1"
                Description = "datetime_1"
                Type = "DATE_TIME"

                DateFormat = 'yyyy-MM-dd'
                TimeFormat = 'HH:mm:ss.SSS'
                DefaultValue = '2019-01-05 09:00:00.000'
                MinValue = '2018-01-16 07:30:10.500'
                MaxValue = '2020-05-01 23:30:10.250'
                Required = $true
                Reporting = $true
                ApplyToAllDispositions = $true
            }

            $create = New-Five9CallVariable @cv_datetime_1
        }


        It "Create test call variable currency_1" {

            $cv_currency_1 = @{
                Group = $module
                Name = "currency_1"
                Description = "currency_1"
                Type = "CURRENCY"
                CurrencyType = "Dollar"

                Required = $true
                DigitsBeforeDecimal = 14
                DigitsAfterDecimal = 2
                MinValue = 1
                MaxValue = 100
                Reporting = $true
                ApplyToAllDispositions = $true
            }

            $create = New-Five9CallVariable @cv_currency_1

        }


        It "Create test call variable bool_1" {

            $cv_bool_1 = @{
                Group = $module
                Name = "bool_1"
                Description = "bool_1"
                Type = "BOOLEAN"

                DefaultValue = $true
                Reporting = $true
                ApplyToAllDispositions = $true
            }

            $create = New-Five9CallVariable @cv_bool_1

        }


        It "Create test call variable percent_1" {

            $cv_percent_1 = @{
                Group = $module
                Name = "percent_1"
                Description = "percent_1"
                Type = "PERCENT"
                CurrencyType = "Dollar"

                Required = $true
                DigitsBeforeDecimal = 16
                DigitsAfterDecimal = 0
                MinValue = 1
                MaxValue = 100
                DefaultValue = 50
                Reporting = $true
                ApplyToAllDispositions = $true
            }

            $create = New-Five9CallVariable @cv_percent_1

        }



    }








    Context ": Modify call variable group" {

        It "Modify call variable group description" {

            $modifyCvGroup = Set-Five9CallVariableGroup -Name $module -Description $($module + "_NewDesc")

        }

        It "Call variable description was modifed correctly" {

            $modifiedCvGroup = Get-Five9CallVariableGroup $module

            $modifiedCvGroup.description | Should -BeExactly $($module + "_NewDesc")

        }

    }



    Context ": Clean up call variable group" {

        It "Delete call variable group" {

            $deleteGroup = Remove-Five9CallVariableGroup -Name $module

        }

        It "Call variable group was deleted" {

            $deletedCvGroup = Get-Five9CallVariableGroup $module

            $modifiedCvGroup | Should -BeNullOrEmpty

        }

    }



}