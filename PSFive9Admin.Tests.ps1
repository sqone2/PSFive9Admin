$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host -ForegroundColor cyan $here
$module = Split-Path -Leaf $here
Write-Host -ForegroundColor Cyan $module

write-host -ForegroundColor White $PSScriptRoot



Describe "Module: $module" -Tag Unit {

    It "Can get admin client" {

        . "$here\Public\SOAPClient\New-Five9AdminClient.ps1"

        $adminClient = New-Five9AdminClient -Username $env:Five9Username -Password $env:Five9Password
        $adminClient.GetType().Name | Should -Be "WsAdminService"

    }

    Context "Module Configuration" {

        It "Has a root module file ($module.psm1)" {

            "$here\$module.psm1" | Should -Exist
        }

        It "Is valid Powershell (Has no script errors)" {

            $contents = Get-Content -Path "$here\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors | Should -HaveCount 0
        }

        It "Has a manifest file ($module.psd1)" {

            "$here\$module.psd1" | Should -Exist
        }

        It "Contains a root module path in the manifest (RootModule = '$module.psm1')" {

            "$here\$module.psd1" | Should -Exist
            "$here\$module.psd1" | Should -FileContentMatch "$module.psm1"
        }


        It "Has a Public folder" {

            "$here\Public" | Should -Exist
        }

        It "Module contains .ps1 files" {

            (Get-ChildItem $here -Recurse  | ? {$_.Name -match '\.ps1$'}).Count | Should -BeGreaterThan 0
        }

        $functions = Get-ChildItem $here -Recurse -ErrorAction SilentlyContinue | ? {$_.Name -match '\.ps1$' -and $_.Name -notmatch '\.Tests\.ps1|build\.ps1'}

        foreach ($function in $functions)
        {
            Context "Function $module::$($function.BaseName)" {
            <#
                It "Has a Pester test" {

                    $function.FullName -replace '.ps1', '.Tests.ps1' | Should -Exist
                }
            #>
                It "Has a Get-Help comment block" {
                    $function.FullName | Should -FileContentMatch '<#'
                    $function.FullName | Should -FileContentMatch '#>'
                }

                It "Get-Help has a .SYNOPSIS" {
                
                    $function.FullName | Should -FileContentMatch '\.SYNOPSIS'
                }

                It "Get-Help has an .EXAMPLE" {
                
                    $function.FullName | Should -FileContentMatch '\.EXAMPLE'
                }

                It "Is an advanced function" {

                    $function.FullName | Should -FileContentMatch 'function'
                    $function.FullName | Should -FileContentMatch 'cmdletbinding'
                    $function.FullName | Should -FileContentMatch 'param'
                }

                It "Is valid Powershell (Has no script errors)" {

                    $contents = Get-Content -Path $function.FullName -ErrorAction Stop
                    $errors = $null
                    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                    $errors | Should -HaveCount 0
                }

                It "Does not contain demoFive9AdminClient" {

                    $function.FullName | Should -Not -FileContentMatch "demoFive9AdminClient"

                }


            }
            
        }

       
    }

    
}