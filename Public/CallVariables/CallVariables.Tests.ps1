$here = $PSScriptRoot
$module = 'PSFive9Admin'

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

$cv_string_2 = @{
    Group = $module
    Name = "string_2"
    Description = "string_2"
    Type = "STRING"

    Required = $true

    Regexp = '^string[0-9]$'

    SensitiveData = $true

    MinValue = "1"
    MaxValue = "7"

}
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


    Context ": Create call variables" {

        It "Create cv_string_1" {

            $createString = New-Five9CallVariable @cv_string_1

        }

            It "Create cv_string_2" {

            $createString = New-Five9CallVariable @cv_string_2

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