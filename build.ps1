
if ($(Get-InstalledModule PSDepend -EA SilentlyContinue) -eq $null)
{
    Install-Module PSDepend -Force
}

Import-Module PSDepend

$modulesToInstall = @{
    PSDeploy = 'latest'
    InvokeBuild = 'latest'
    Pester = 'latest'
}


Invoke-PSDepend -InputObject $modulesToInstall -Install -Import -Force


Invoke-Build -Task Test -Result result -ErrorAction: SilentlyContinue

if ($result.Error)
{
    Write-Host -ForegroundColor Cyan 'exit 1'
    #exit 1
}
else 
{
    Write-Host -ForegroundColor Cyan 'exit 0'    
    #exit 0
}