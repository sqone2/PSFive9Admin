<#
.SYNOPSIS
    
    Function used to delete a skill
 
.DESCRIPTION
 
    Function used to delete a skill
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client


.PARAMETER SkillName
 
    Skill name to be deleted

   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Remove-Five9Skill -Five9AdminClient $adminClient -SkillName "MultiMedia"
    
    # Deletes skill named MultiMedia
    

#>
function Remove-Five9Skill
{
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$SkillName
    )

    $response = $Five9AdminClient.deleteSkill($SkillName)

    return $response

}