<#
.SYNOPSIS
    
    Function used to return contact field(s) from Five9
 
.PARAMETER Name

    Name of existing contact field. If omitted, all contact fields will be returned

.EXAMPLE

    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Get-Five9ContactField -Five9AdminClient $adminClient

    # Returns all contact fields

.EXAMPLE
    
    Get-Five9ContactField -Five9AdminClient $adminClient -Name "first_name"
    
    # Returns contact field with name ""first_name"

#>
function New-Five9ContactField
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][ValidateSet('STRING','NUMBER','DATE','TIME','DATE_TIME','CURRENCY','BOOLEAN','PERCENT','EMAIL','URL','PHONE','TIME_PERIOD')][string]$Type = 'STRING',
        [Parameter(Mandatory=$false)][ValidateSet('None','LastDisposition','LastSystemDisposition','LastAgentDisposition','LastDispositionDateTime','LastSystemDispositionDateTime','LastAgentDispositionDateTime','LastAttemptedNumber','LastAttemptedNumberN1N2N3','LastCampaign','AttemptsForLastCampaign','LastList','CreatedDateTime','LastModifiedDateTime')][string]$MapTo = 'None',
        [Parameter(Mandatory=$false)][ValidateSet('Short', 'Long', 'Invisible')][string]$DisplayAs = 'Short',
        
        [Parameter(Mandatory=$true)][string]$restrictions,
        [Parameter(Mandatory=$true)][string]$System
        
    )

    $contactField = New-Object PSFive9Admin.contactField

    return $Five9AdminClient.createContactField($NamePattern)

}
