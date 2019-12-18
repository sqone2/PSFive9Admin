
#Requires -Modules 'InvokeBuild'

# Importing all build settings into the current scope
. "$PSScriptRoot\$(Split-Path -Leaf $PSScriptRoot).BuildSettings.ps1"

<#
Set-BuildHeader {
    Param($Path)
    Write-Build Cyan "Task $Path"
    "`n" + ('-' * 79) + "`n" + "`t`t`t $($Task.Name.ToUpper()) `n" + ('-' * 79) + "`n"
}
#>

task Clean {

    if (Test-Path -Path $Settings.BuildOutput) 
    {
        "Removing existing files and folders in $($Settings.BuildOutput)\"
        Get-ChildItem $Settings.BuildOutput | Remove-Item -Force -Recurse
    }
    else 
    {
        "$($Settings.BuildOutput) is not present, nothing to clean up."
        $null = New-Item -ItemType Directory -Path $Settings.BuildOutput
    }

}

task Install_Dependencies {
    # PSDpend gets installed in main build script
    $PSDependParams = $Settings.PSDependParams
    Invoke-PSDepend @PSDependParams
}

task Test {
    $PesterParams = $Settings.PesterParams
    $Script:TestsResult = Invoke-Pester @PesterParams
}

task Fail_If_Failed_Unit_Test {
    $FailureMessage = "$($TestsResult.FailedCount) Unit test(s) failed. Aborting build."
    assert ($TestsResult.FailedCount -eq 0) $FailureMessage
}

task Upload_Test_Results_To_AppVeyor {

    $TestResultFiles = (Get-ChildItem -Path $Settings.BuildOutput -Filter '*TestsResult.xml').FullName

    foreach ( $TestResultFile in $TestResultFiles ) 
    {
        "Uploading test result file : $TestResultFile"
        (New-Object 'System.Net.WebClient').UploadFile($Settings.TestUploadUrl, $TestResultFile)
    }

}

task Analyze {
    Add-AppveyorTest -Name 'Code Analysis' -Outcome Running
    $AnalyzeSettings = $Settings.AnalyzeParams
    $Script:AnalyzeFindings = Invoke-ScriptAnalyzer @AnalyzeSettings

    if ($AnalyzeFindings) 
    {
        $FindingsString = $AnalyzeFindings | Out-String
        Write-Warning $FindingsString
        Update-AppveyorTest -Name 'Code Analysis' -Outcome Failed -ErrorMessage $FindingsString
    }
    else 
    {
        Update-AppveyorTest -Name 'Code Analysis' -Outcome Passed
    }
}

task Fail_If_Analyze_Findings {
    $FailureMessage = 'PSScriptAnalyzer found {0} issues. Aborting build' -f $AnalyzeFindings.Count
    assert ( -not($AnalyzeFindings) ) $FailureMessage
}

task Set_Module_Version {
    $ManifestContent = Get-Content -Path $Settings.ManifestPath
    $CurrentVersion = $Settings.VersionRegex.Match($ManifestContent).Groups['ModuleVersion'].Value
    "Current module version in the manifest : $CurrentVersion"

    $ManifestContent -replace $CurrentVersion,$Settings.Version | Set-Content -Path $Settings.ManifestPath -Force
    $NewManifestContent = Get-Content -Path $Settings.ManifestPath
    $NewVersion = $Settings.VersionRegex.Match($NewManifestContent).Groups['ModuleVersion'].Value
    "Updated module version in the manifest : $NewVersion"

    if ($NewVersion -ne $Settings.Version) 
    {
        throw "Module version was not updated correctly to $($Settings.Version) in the manifest."
    }
}

task Push_Build_Changes_To_Repo {
    cmd /c "git config --global credential.helper store 2>&1"    
    Add-Content "$env:USERPROFILE\.git-credentials" "https://$($Settings.GitHubKey):x-oauth-basic@github.com`n"
    cmd /c "git config --global user.email ""$($Settings.GitHubEmail)"" 2>&1"
    cmd /c "git config --global user.name ""$($Settings.GitHubUsername)"" 2>&1"
    cmd /c "git config --global core.autocrlf true 2>&1"
    cmd /c "git checkout $($Settings.Branch) 2>&1"
    cmd /c "git add -A 2>&1"
    cmd /c "git commit -m ""Commit build changes [ci skip]"" 2>&1"
    cmd /c "git status 2>&1"
    cmd /c "git push origin $($Settings.Branch) 2>&1"
}

task Copy_Source_To_Build_Output {
    "Copying the source folder [$($Settings.SourceFolder)] into the build output folder : [$($Settings.BuildOutput)]"
    Copy-Item -Path $Settings.SourceFolder -Destination $Settings.BuildOutput -Recurse
}

task Publish_Module_To_PSGallery {
    Remove-Module -Name $($Settings.ModuleName) -Force -ErrorAction SilentlyContinue

    Write-Host "OutputModulePath : $($Settings.OutputModulePath)"
    Write-Host "PSGalleryKey : $($($Settings.PSGalleryKey).Substring(0,4))**********"
    Get-PackageProvider -ListAvailable
    Publish-Module -Path $Settings.OutputModulePath -NuGetApiKey $Settings.PSGalleryKey -Verbose
}

# Default task :
task . Clean,
       Install_Dependencies,
       Test,
       Fail_If_Failed_Unit_Test,
       Upload_Test_Results_To_AppVeyor,
       Analyze,
       Fail_If_Analyze_Findings,
       Set_Module_Version,
       Push_Build_Changes_To_Repo,
       Copy_Source_To_Build_Output,
       Publish_Module_To_PSGallery