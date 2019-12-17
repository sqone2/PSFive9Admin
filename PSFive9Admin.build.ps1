<#
$Script:ModuleName = Get-ChildItem .\*\*.psm1 | Select-object -ExpandProperty BaseName
$Script:CodeCoveragePercent = 0.0 # 0 to 1
. $psscriptroot\BuildTasks\InvokeBuildInit.ps1

task Default Build, Helpify, Test, UpdateSource
task Build Copy, Compile, BuildModule, BuildManifest, SetVersion
task Helpify GenerateMarkdown, GenerateHelp
task Test Build, ImportModule, Pester
task Publish Build, PublishVersion, Helpify, Test, PublishModule
task TFS Clean, Build, PublishVersion, Helpify, Test
task DevTest ImportDevModule, Pester

Write-Host 'Import common tasks'
Get-ChildItem -Path $buildroot\BuildTasks\*.Task.ps1 |
    ForEach-Object {Write-Host $_.FullName;. $_.FullName}
    
#>

<#
task InstallDependencies {
    Install-Module Pester -Force
    Install-Module PSScriptAnalyzer -Force
}
#>

task Analyze {
    $scriptAnalyzerParams = @{
        Path = $BuildRoot
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
        ExcludeRule = 'PSUseDeclaredVarsMoreThanAssignments'
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}

task Test {
    $invokePesterParams = @{
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;
    <#
    $numberFails = $testResults.FailedCount
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)
    #>
}