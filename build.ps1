Write-Host "Build version :`  $env:APPVEYOR_BUILD_VERSION"
Write-Host "Branch        :`  $env:APPVEYOR_REPO_BRANCH"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-Host -ForegroundColor Green "Installing module: InvokeBuild"
Install-Module InvokeBuild -Force -SkipPublisherCheck
Import-Module InvokeBuild

Write-Host -ForegroundColor Green "Installing module: PSDepend"
Install-Module PSDepend -Force -SkipPublisherCheck
Import-Module PSDepend

Invoke-Build # -Task Test -Result result -ErrorAction: SilentlyContinue
