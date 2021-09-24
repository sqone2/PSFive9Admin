$here = $PSScriptRoot
Write-Host -ForegroundColor cyan $here
$module = Split-Path -Leaf $PSScriptRoot
Write-Host -ForegroundColor Cyan $module

Write-Host -ForegroundColor White $PSScriptRoot

Describe "Module: $module" -Tag Unit {

    It "Can connect to Five9 admin web service" {

        {Import-Module "$here\$module.psm1" -Force} | Should -Not -Throw

        $username = $env:Five9Username
        $password = $env:Five9Password | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object -TypeName PSCredential -ArgumentList $username,$password
        Connect-Five9AdminWebService -Credential $cred

        $global:DefaultFive9AdminClient.GetType().Name | Should -Be "WsAdminService"
        $global:DefaultFive9AdminClient.Five9DomainName.Length | Should -BeGreaterThan 0

    }

    
    Context "Unit Tests" {

        Invoke-Pester "$here\Public"

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

        $functions = Get-ChildItem $here -Recurse -ErrorAction SilentlyContinue | ? {$_.Name -match '\.ps1$' -and $_.Name -notmatch '\.Tests\.ps1|build\.ps1|BuildSettings' -and $_.FullName -notmatch 'assets'}

        foreach ($function in $functions)
        {
            Context "Function $module::$($function.BaseName)" {

                #It "Has a Pester test" {
                #
                #    $function.FullName -replace '.ps1', '.Tests.ps1' | Should -Exist
                #}


                It "File name matches function name" {
                    $function.FullName | Should -FileContentMatch "function $($function.BaseName)"
                }

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


            }
            
        }

       
    }
    
}