 # Adjust this path
$filePath = 'C:\Temp\Master-Skills.csv'

$users = Get-Five9User

$skillList = @()

foreach ($user in $users)
{
    foreach ($userSkill in $user.skills)
    {
        $userSkill | Add-Member -MemberType NoteProperty -Name type -Value user
        $userSkill | Add-Member -MemberType NoteProperty -Name userName -Value $user.username -Force
        $userSkill | Add-Member -MemberType NoteProperty -Name name -Value $user.fullName -Force
        $userSkill | Add-Member -MemberType NoteProperty -Name active -Value $user.active -Force
        $userSkill | Add-Member -MemberType NoteProperty -Name userProfileName -Value $user.userProfileName -Force

        $skillList += $userSkill | select type,active,name,userProfileName,userName,skillName,level
    }
}

$userProfiles = Get-Five9UserProfile

foreach ($profile in $userProfiles)
{
    foreach ($profileSkill in $profile.skills)
    {
        $skillList += New-Object psobject -Property @{
            type = 'profile'
            name = $profile.name
            skillName = $profileSkill
        } | select type,name,skillName

    }
    
}

$skillList | Export-Csv $filePath -NoTypeInformation

 
