<#
.SYNOPSIS
    
    Function used to modify an existing campaign profile in Five9
 
.PARAMETER Name

    Name of existing campaign profile

.PARAMETER Description

     Description of existing campaign profile

.PARAMETER InitialCallPriority

    Priority initially assigned to inbound and outbound calls on a scale of 1 to 100. 
    Inbound calls have a default priority of 60. 
    Calls with a higher priority are answered first, regardless of their time in a queue. 
    To force calls from a campaign to be answered before those from other campaigns, increase the priority by 1.

.PARAMETER MaxCharges

    Applies to inbound and outbound calls. 
    Maximum dollar amount for long distance charges. 
    The campaign stops automatically when this amount is reached. 
    Zero means no limit.

.PARAMETER DialingTimeout

    Time to wait before disconnecting an unanswered call and logging it as No Answer.
    The default is 17 seconds


.PARAMETER NumberOfAttempts

    For outbound campaigns, number of dialing attempts for phone numbers in a list record, including redials due to disposition settings

.PARAMETER ANI

    ANI to send with outbound call

. PARAMETER IncludeNumber1

    Whether to call number1 in the campaign associated with the profile

. PARAMETER IncludeNumber2

    Whether to call number2 in the campaign associated with the profile

. PARAMETER IncludeNumber3

    Whether to call number3 in the campaign associated with the profile

. PARAMETER Number1StartTime

    When, in local time, to start dialing number1 numbers for an outbound campaign. i.e. '8am' or '8:30am'

. PARAMETER Number1StopTime

    When, in local time, to stop dialing number1 numbers. i.e. '7pm' or '7:30pm'

. PARAMETER Number2StartTime

    When, in local time, to start dialing number2 numbers for an outbound campaign. i.e. '8am' or '8:30am'

. PARAMETER Number2StopTime

    When, in local time, to stop dialing number2 numbers. i.e. '7pm' or '7:30pm'


. PARAMETER Number3StartTime

    When, in local time, to start dialing number3 numbers for an outbound campaign. i.e. '8am' or '8:30am'

. PARAMETER Number3StopTime

    When, in local time, to stop dialing number3 numbers. i.e. '7pm' or '7:30pm'


. PARAMETER DialingOrder

    Contains the dialing order of phone numbers when contact records have multiple phone numbers. i.e. -DialingOrder 'Number1', 'Number2', 'Number3'

. PARAMETER DialASAPTimeout

    Duration before records that are not dialed are removed from the ASAP queue and are treated as normal records

. PARAMETER DialASAPTimeoutPeriod

    Unit that specifies the dial ASAP timeout
    Options are:
        • Second 
        • Minute
        • Hour
        • Day

. PARAMETER DialASAPSortOrder
    
    Order for dialing numbers in the ASAP queue
    Options are:
    • FIFO (Default) - First in, first out: oldest added are called first
    • LIFO - Last in, first out: newest added called first
    • ContactFields - Sort order of the campaign profile


. NOTES

    Campaign profiles cannot be renamed using the API


.EXAMPLE

    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9CampaignProfile -Five9AdminClient $adminClient -Name "Cold-Calls-Profile" -InitialCallPriority 90 -NumberOfAttempts 10 -ANI '5991230001' `
                             -IncludeNumber1 $true -IncludeNumber2: $false -IncludeNumber3 $false `
                             -Number1StartTime 9am -Number1StopTime 10am -Number2StartTime 9am -Number2StopTime 10pm -Number3StartTime 10am -Number3StopTime 11pm `
                             -DialingOrder 'Number3', 'Number1', 'number2' -DialASAPTimeout 9 -DialASAPTimeoutPeriod: Minute -DialASAPSortOrder: ContactFields


    # Modifies existing campaign profile

.EXAMPLE
    
    
    Set-Five9CampaignProfile -Five9AdminClient $adminClient -Name "Cold-Calls-Profile" `
                             -Number1StopTime '10pm' -DialingOrder 'Number1', 'Number3', 'Number2' `
                             -DialASAPTimeout 4 -DialASAPTimeoutPeriod: Hour -DialASAPSortOrder: FIFO
    
    # Modifies existing campaign profile's dialing schedule

#>
function Set-Five9CampaignProfile
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][ValidateRange(1,100)][int]$InitialCallPriority,
        [Parameter(Mandatory=$false)][int]$MaxCharges,
        [Parameter(Mandatory=$false)][ValidateRange(10,2147483)][int]$DialingTimeout,
        [Parameter(Mandatory=$false)][ValidateRange(1,127)][int]$NumberOfAttempts,
        [Parameter(Mandatory=$false)][string]$ANI,

        [Parameter(Mandatory=$false)][bool]$IncludeNumber1,
        [Parameter(Mandatory=$false)][bool]$IncludeNumber2,
        [Parameter(Mandatory=$false)][bool]$IncludeNumber3,

        [Parameter(Mandatory=$false)][datetime]$Number1StartTime,
        [Parameter(Mandatory=$false)][datetime]$Number1StopTime,

        [Parameter(Mandatory=$false)][datetime]$Number2StartTime,
        [Parameter(Mandatory=$false)][datetime]$Number2StopTime,

        [Parameter(Mandatory=$false)][datetime]$Number3StartTime,
        [Parameter(Mandatory=$false)][datetime]$Number3StopTime,

        [Parameter(Mandatory=$false)][ValidatePattern('Number[1-3]')][string[]]$DialingOrder,

        [Parameter(Mandatory=$false)][int]$DialASAPTimeout,
        [Parameter(Mandatory=$false)][ValidateSet('Second', 'Minute', 'Hour', 'Day')][string]$DialASAPTimeoutPeriod,
        [Parameter(Mandatory=$false)][ValidateSet('LIFO', 'FIFO', 'ContactFields')][string]$DialASAPSortOrder

    )

    $campaignProfileToModify = $null
    try
    {
        $campaignProfileToModify = $Five9AdminClient.getCampaignProfiles($Name)
    }
    catch
    {

    }
    
    if ($campaignProfileToModify.Count -gt 1)
    {
        throw "Multiple campaign profiles were found using query: ""$Name"". Please try using the exact name of the campaign profile you're trying to modify."
        return
    }

    if ($campaignProfileToModify -eq $null)
    {
        throw "Cannot find a campaign profile with name: ""$Name"". Remember that Name is case sensitive."
        return
    }

    $campaignProfileToModify = $campaignProfileToModify | select -First 1
    

    if ($PSBoundParameters.Keys -contains 'Description')
    {
        $campaignProfileToModify.description = $Description
    }

    if ($PSBoundParameters.Keys -contains 'InitialCallPriority')
    {
        $campaignProfileToModify.initialCallPriority = $InitialCallPriority
        $campaignProfileToModify.initialCallPrioritySpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'MaxCharges')
    {
        $campaignProfileToModify.maxCharges = $MaxCharges
        $campaignProfileToModify.maxChargesSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'DialingTimeout')
    {
        $campaignProfileToModify.dialingTimeout = $DialingTimeout
        $campaignProfileToModify.dialingTimeoutSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'NumberOfAttempts')
    {
        $campaignProfileToModify.numberOfAttempts = $NumberOfAttempts
        $campaignProfileToModify.numberOfAttemptsSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'ANI')
    {
        $campaignProfileToModify.ANI = $ANI
    }

    if ($PSBoundParameters.Keys -contains 'IncludeNumber1')
    {
        if ($IncludeNumber1 -eq $true)
        {
            if ($campaignProfileToModify.dialingSchedule.includeNumbers -notcontains 'Primary')
            {
                $campaignProfileToModify.dialingSchedule.includeNumbers += 'Primary'
            }
        }
        else
        {
            $campaignProfileToModify.dialingSchedule.includeNumbers = $campaignProfileToModify.dialingSchedule.includeNumbers | ? {$_ -ne 'Primary'}
        }

    }

    if ($PSBoundParameters.Keys -contains 'IncludeNumber2')
    {
        if ($IncludeNumber1 -eq $true)
        {
            if ($campaignProfileToModify.dialingSchedule.includeNumbers -notcontains 'Alt1')
            {
                $campaignProfileToModify.dialingSchedule.includeNumbers += 'Alt1'
            }
        }
        else
        {
            $campaignProfileToModify.dialingSchedule.includeNumbers = $campaignProfileToModify.dialingSchedule.includeNumbers | ? {$_ -ne 'Alt1'}
        }

    }

    if ($PSBoundParameters.Keys -contains 'IncludeNumber3')
    {
        if ($IncludeNumber1 -eq $true)
        {
            if ($campaignProfileToModify.dialingSchedule.includeNumbers -notcontains 'Alt2')
            {
                $campaignProfileToModify.dialingSchedule.includeNumbers += 'Alt2'
            }
        }
        else
        {
            $campaignProfileToModify.dialingSchedule.includeNumbers = $campaignProfileToModify.dialingSchedule.includeNumbers | ? {$_ -ne 'Alt2'}
        }

    }

    # number1 start/stop
    if ($PSBoundParameters.Keys -contains 'Number1StartTime')
    {
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Primary'}).startTime.hours = $Number1StartTime.Hour
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Primary'}).startTime.minutes = $Number1StartTime.Minute
    }

    if ($PSBoundParameters.Keys -contains 'Number1StopTime')
    {
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Primary'}).stopTime.hours = $Number1StopTime.Hour
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Primary'}).stopTime.minutes = $Number1StopTime.Minute
    }



    # number2 start/stop
    if ($PSBoundParameters.Keys -contains 'Number2StartTime')
    {
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt1'}).startTime.hours = $Number2StartTime.Hour
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt1'}).startTime.minutes = $Number2StartTime.Minute
    }

    if ($PSBoundParameters.Keys -contains 'Number2StopTime')
    {
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt1'}).stopTime.hours = $Number2StopTime.Hour
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt1'}).stopTime.minutes = $Number2StopTime.Minute
    }


    # number3 start/stop
    if ($PSBoundParameters.Keys -contains 'Number3StartTime')
    {
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt2'}).startTime.hours = $Number3StartTime.Hour
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt2'}).startTime.minutes = $Number3StartTime.Minute
    }

    if ($PSBoundParameters.Keys -contains 'Number3StopTime')
    {
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt2'}).stopTime.hours = $Number3StopTime.Hour
        ($campaignProfileToModify.dialingSchedule.dialingSchedules | ? {$_.number -eq 'Alt2'}).stopTime.minutes = $Number3StopTime.Minute
    }

    if ($PSBoundParameters.Keys -contains 'DialingOrder')
    {
        if ($DialingOrder.Count -ne 3)
        {
            throw "Parameter ""-DialingOrder"" must be an array that contains 3 strings in the order you would like to dial. i.e. -DialingOrder 'Number1', 'Number2', 'Number3'"
            return
        }

        $dialOrderMapping = @{
            'Number1,Number2,Number3' = 'PrimaryAlt1Alt2'
            'Number1,Number3,Number2' = 'PrimaryAlt2Alt1'
            'Number2,Number1,Number3' = 'Alt1PrimaryAlt2'
            'Number2,Number3,Number1' = 'Alt1Alt2Primary'
            'Number3,Number1,Number2' = 'Alt2PrimaryAlt1'
            'Number3,Number2,Number1' = 'Alt2Alt1Primary'
        }

        $dialOrderString = $dialOrderMapping[$DialingOrder -join ',']

        if ($dialOrderString.Length -lt 5)
        {
            Write-Warning -Message 'There was an error processing the DialingOrder parameter. Dialing order will not be modified on this campign profile. Please see ""Get-Help Set-Five9CampaignProfileSchedule -Full"" ' -ErrorAction: Continue
        }
        else
        {
            $campaignProfileToModify.dialingSchedule.dialingOrder = $dialOrderString
            $campaignProfileToModify.dialingSchedule.dialingOrderSpecified = $dialOrderString
        }

    }


    if ($PSBoundParameters.Keys -contains 'DialASAPTimeout')
    {
        $campaignProfileToModify.dialingSchedule.dialASAPTimeout = $DialASAPTimeout
        $campaignProfileToModify.dialingSchedule.dialASAPTimeoutSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'DialASAPTimeoutPeriod')
    {
        $campaignProfileToModify.dialingSchedule.dialASAPTimeoutPeriod = $DialASAPTimeoutPeriod
        $campaignProfileToModify.dialingSchedule.dialASAPTimeoutPeriodSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'DialASAPSortOrder')
    {
        $campaignProfileToModify.dialingSchedule.dialASAPSortOrder = $DialASAPSortOrder
        $campaignProfileToModify.dialingSchedule.dialASAPSortOrderSpecified = $true
    }
    
    $response = $Five9AdminClient.modifyCampaignProfile($campaignProfileToModify)

    return $response

}
