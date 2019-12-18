# This file stores variables which are used by the build script

# Storing all values in a single $Settings variable to make it obvious that the values are coming from this BuildSettings file when accessing them.


$Settings = @{

    BuildOutput = "$PSScriptRoot\BuildOutput"
    Dependencies = @('Pester','PsScriptAnalyzer')
    SourceFolder = $PSScriptRoot
    TestUploadUrl = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
    Branch = $env:APPVEYOR_REPO_BRANCH


    PesterParams = @{
        #Script = '.\Tests\Unit'
        #CodeCoverage = (Get-ChildItem -Path $here -File -Filter "*.ps1" -Recurse).FullName | Where-Object { $_ -Match "Public|Private" }
        OutputFile = "$PSScriptRoot\BuildOutput\UnitTestsResult.xml"
        PassThru = $True
        Strict = $true
    }

    PSDependParams = @{

        InputObject = @{
            PSDeploy = 'latest'
            Pester = 'latest'
            PSScriptAnalyzer = 'latest'
        }

         Install = $true 
         Import = $true
         Force = $true 
         #Verbose = $true
         ErrorAction = "Stop"

    }



    AnalyzeParams = @{
        Path = $PSScriptRoot
        Severity = 'Error'
        Recurse = $True
    }


    Version = $env:APPVEYOR_BUILD_VERSION
    ManifestPath = "$PSScriptRoot\$(Split-Path -Leaf $PSScriptRoot).psd1"
    VersionRegex = "ModuleVersion\s=\s'(?<ModuleVersion>\S+)'" -as [regex]

    GitHubKey = $env:GitHubKey
    GitHubEmail = $env:GitHubEmail
    GitHubUsername = $env:GitHubUsername
    
    ModuleName = Split-Path -Leaf $PSScriptRoot

    PSGalleryKey = $env:NugetApiKey
    OutputModulePath = "$PSScriptRoot\BuildOutput\$($env:APPVEYOR_PROJECT_NAME)"
}