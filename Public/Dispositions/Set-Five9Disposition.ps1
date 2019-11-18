<#
.SYNOPSIS
    
    Function used to modify a Five9 disposition
 
.DESCRIPTION
 
    Function used to modify a Five9 disposition
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER Name

    Name of existing disposition

.PARAMETER NewName

    Optional parameter. If provided, existing disposition's name will be changed

.PARAMETER Description

    Description of disposition

.PARAMETER AgentMustCompleteWorksheet

    Whether the agent needs to complete a worksheet before selecting a disposition

.PARAMETER AgentMustConfirm

    Whether the agent is prompted tconfirm the selection of the disposition

.PARAMETER ResetAttemptsCounter

    Whether the agent is prompted to confirm the selection of the disposition

.PARAMETER SendEmailNotification

    Whether call details are sent as an email notification when the disposition is used by an agent

.PARAMETER SendIMNotification

    Whether call details are sent as an instant message in the Five9 system when the disposition is used by an agent

.PARAMETER TrackAsFirstCallResolution

    Whether the call is included in the first call resolution statistics (customer’s needs addressed in the first call). Used primarily for inbound campaigns

.PARAMETER Type

    Type of disposition

.PARAMETER UseRedialTimer

    Whether this disposition uses a redial timer
    Only used when -Type is set to "RedialNumber"

.PARAMETER RedialAttempts

    Number of redial attempts. 
    Only used when -Type is set to "RedialNumber"

.PARAMETER AllowChangeTimer

    Whether the agent can change the redial timer for this disposition
    Only used when -Type is set to "RedialNumber"

.PARAMETER RedialTimerDays

    Number of Days
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"

.PARAMETER RedialTimerHours

    Number of Hours
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"

.PARAMETER RedialTimerMinutes

    Number of Minutes
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"

.PARAMETER RedialTimerSeconds
    
    Number of Seconds
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"


   
.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9Disposition -Five9AdminClient $adminClient -Name "Default-Disposition" -NewName "Old-Disposition" -Type: AddActiveNumber

    # Changes existing disposition from "Default-Disposition" to "Old-Disposition", and changes Type to "AddActiveNumber"
    
    
 
#>
function Set-Five9Disposition
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$NewName,

        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][bool]$AgentMustCompleteWorksheet,
        [Parameter(Mandatory=$false)][bool]$AgentMustConfirm,
        [Parameter(Mandatory=$false)][bool]$ResetAttemptsCounter,
        [Parameter(Mandatory=$false)][bool]$SendEmailNotification,
        [Parameter(Mandatory=$false)][bool]$SendIMNotification,
        [Parameter(Mandatory=$false)][bool]$TrackAsFirstCallResolution,

        [Parameter(Mandatory=$false)][ValidateSet("FinalDisp", "FinalApplyToCampaigns", "AddActiveNumber", "AddAndFinalize", "AddAllNumbers", "DoNotDial", "RedialNumber")][string]$Type,

        [Parameter(Mandatory=$false)][bool]$UseRedialTimer,
        [Parameter(Mandatory=$false)][ValidateRange(1,99)][int]$RedialAttempts,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerDays,
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$RedialTimerHours,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerMinutes,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerSeconds,

        [Parameter(Mandatory=$false)][string]$AllowChangeTimer

    )

    $dispositionToModify = $null
    try
    {
        $dispositionToModify = $Five9AdminClient.getDispositions($Name) | select -First 1
    }
    catch
    {

    }
    
    if ($dispositionToModify.Count -gt 1)
    {
        throw "Multiple Dispositions were found using query: ""$Name"". Please try using the exact name of the disposition you're trying to modify."
        return
    }

    if ($dispositionToModify -eq $null)
    {
        throw "Cannot find a Disposition with name: ""$Name"". Remember that Name is case sensitive."
        return
    }

    if ($PSBoundParameters.Keys -contains "Description")
    {
        $dispositionToModify.description = $Description
    }
    
    if ($PSBoundParameters.Keys -contains "AgentMustCompleteWorksheet")
    {
        $dispositionToModify.agentMustCompleteWorksheet = $AgentMustCompleteWorksheet
        $dispositionToModify.agentMustCompleteWorksheetSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "AgentMustConfirm")
    {
        $dispositionToModify.agentMustConfirm = $AgentMustConfirm
        $dispositionToModify.agentMustConfirmSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "ResetAttemptsCounter")
    {
        $dispositionToModify.resetAttemptsCounter = $ResetAttemptsCounter
        $dispositionToModify.resetAttemptsCounterSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "SendEmailNotification")
    {
        $dispositionToModify.sendEmailNotification = $SendEmailNotification
        $dispositionToModify.sendEmailNotificationSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "SendIMNotification")
    {
        $dispositionToModify.sendIMNotification = $SendIMNotification
        $dispositionToModify.sendIMNotificationSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "TrackAsFirstCallResolution")
    {
        $dispositionToModify.trackAsFirstCallResolution = $TrackAsFirstCallResolution
        $dispositionToModify.trackAsFirstCallResolutionSpecified = $true
    }
    
   
    if ($PSBoundParameters.Keys -contains "Type")
    {
        $dispositionToModify.type = $Type
        $dispositionToModify.typeSpecified = $true

         # only set timer values if type is set to RedialNumber
        if ($Type -eq "RedialNumber" -and $PSBoundParameters.Keys -contains "UseRedialTimer")
        {
            $dispositionToModify.typeParameters = New-Object PSFive9Admin.dispositionTypeParams

            $dispositionToModify.typeParameters.useTimer = $UseRedialTimer
            $dispositionToModify.typeParameters.useTimerSpecified = $true

            if ($UseRedialTimer -eq $true)
            {
                if ($RedialAttempts -lt 1)
                {
                    throw "When -UseRedialTimer is set to True, you must also set -RedialAttempts to a value between 1-99."
                    return
                }

                if ($RedialTimerDays -lt 1 -and $RedialTimerHours -lt 1 -and $RedialTimerMinutes -lt 1)
                {
                    throw "When -UseRedialTimer is set to True, the total -RedailTimer<unit> values must be set to at least 1 minute. For example, to redial a record after 8.5 hours, use -RedialTimerHours 8 -RedialTimerMinutes -30"
                    return
                }

                $dispositionToModify.typeParameters.timer = New-Object PSFive9Admin.timer
                $dispositionToModify.typeParameters.timer.days = $RedialTimerDays
                $dispositionToModify.typeParameters.timer.hours = $RedialTimerHours
                $dispositionToModify.typeParameters.timer.minutes = $RedialTimerMinutes
                $dispositionToModify.typeParameters.timer.seconds = $RedialTimerSeconds

                $dispositionToModify.typeParameters.attempts = $RedialAttempts
                $dispositionToModify.typeParameters.attemptsSpecified = $true

            }

            if ($PSBoundParameters.Keys -contains "AllowChangeTimer")
            {
                $dispositionToModify.typeParameters.allowChangeTimer = $AllowChangeTimer
                $dispositionToModify.typeParameters.allowChangeTimerSpecified = $true
            }

        }

    }


    try
    {
        $response =  $Five9AdminClient.modifyDisposition($dispositionToModify)

        if ($PSBoundParameters.Keys -contains "NewName")
        {
            $response =  $Five9AdminClient.renameDisposition($Name, $NewName)
        }

        return $response
    
    }
    catch
    {
        throw $_
    }

}

