<#
.SYNOPSIS
    
    Function used to create a new contact field
 

.PARAMETER Name

    Name of new contact field

.PARAMETER MapTo

    Map of the system information into the field. The field is updated when a disposition is set
    Options are:
        • None (Default)
        • LastAgent - Name of last logged-in agent.
        • LastDisposition - Name of last disposition assigned to a call.
        • LastSystemDisposition - Name of last system disposition assigned to a call.
        • LastAgentDisposition - Name of last disposition assigned by an agent to a call.
        • LastDispositionDateTime - Date and time of last disposition assigned to a call.
        • LastSystemDispositionDateTime - Date and time of last system disposition assigned to a call.
        • LastAgentDispositionDateTime - Date and time of last disposition assigned by an agent to a call.
        • LastAttemptedNumber - Last number attempted by the dialer or by an agent.
        • LastAttemptedNumberN1N2N3 - Index of the last dialed phone number in the record: number1, number2 or number3

        Note: a domain can only contain one contact field for each mapping

.PARAMETER DisplayAs

    Display options for the data in the Agent desktop
    Options are:
        • Short (Default) - Half line
        • Long - Full line
        • Invisible - Not represented

.PARAMETER Required

    Whether the field must contain a value

.PARAMETER PredefinedList

    Single string, or array of multiple strings which are the only possible values for this field to be set to

.PARAMETER CanSelectMultiple

    Whether multiple values from PredefinedList can be selected as value

.PARAMETER MinValue

    Minimum value

.PARAMETER MaxValue

    Maximum value

.PARAMETER Regexp
    
    Regular expression that field value must match

.PARAMETER DigitsBeforeDecimal

    Digits before decimal point

.PARAMETER DigitsAfterDecimal

    Digits after decimal point

.PARAMETER TimeFormat

    Time format string. i.e. yyyy-MM-dd

.PARAMETER DateFormat

    Time format string. i.e. HH:mm:ss.SSS

.PARAMETER TimePeriodFormat

    Time format string. i.e. hh:mm:ss.SSS

.PARAMETER CurrencyType

    Type of currency
    Options are:
        • Dollar
        • Euro
        • Pound


.EXAMPLE
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9ContactField -Five9AdminClient $demoFive9AdminClient -Name 'hair_color'

    # Creates new contact field using default values

.EXAMPLE

    $preDefinedList = @('Brown', 'Blue', 'Green')
    New-Five9ContactField -Five9AdminClient $demoFive9AdminClient -Name 'eye_color' -PredefinedList $preDefinedList -CanSelectMultiple: $false

    # Creates new contact field including a list of predefined items

.EXAMPLE

    New-Five9ContactField -Five9AdminClient $demoFive9AdminClient -Name 'date_of_hire' -DateFormat -Type: DATE -DateFormat 'yyyy-MM-dd' -TimeFormat 'HH:mm:ss.SSS'

    # Creates new contact field as date type

#>
function Set-Five9ContactField
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][ValidateSet('None','LastDisposition','LastSystemDisposition','LastAgentDisposition','LastDispositionDateTime','LastSystemDispositionDateTime','LastAgentDispositionDateTime','LastAttemptedNumber','LastAttemptedNumberN1N2N3','LastCampaign','AttemptsForLastCampaign','LastList','CreatedDateTime','LastModifiedDateTime')][string]$MapTo,
        [Parameter(Mandatory=$false)][ValidateSet('Short', 'Long', 'Invisible')][string]$DisplayAs,

        # Restrictions
        [Parameter(Mandatory=$false)][string[]]$PredefinedListAddition
    )

    $contactFieldToModify = $null
    try
    {
        $contactFieldToModify = $Five9AdminClient.getContactFields($Name)
    }
    catch
    {

    }
    
    if ($contactFieldToModify.Count -gt 1)
    {
        throw "Multiple contact fields were found using query: ""$Name"". Please try using the exact name of the contact field you're trying to modify."
        return
    }

    if ($contactFieldToModify -eq $null)
    {
        throw "Cannot find a contact field with name: ""$Name"". Remember that Name is case sensitive."
        return
    }

    $contactFieldToModify = $contactFieldToModify | select -First 1


    if ($PSBoundParameters.Keys -contains 'MapTo')
    {
        $contactFieldToModify.mapTo = $MapTo
        $contactFieldToModify.mapToSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'DisplayAs')
    {
        $contactFieldToModify.displayAs = $DisplayAs
        $contactFieldToModify.displayAsSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'PredefinedListAddition')
    {
        foreach ($item in $PredefinedListAddition)
        {
            $restriction = New-Object PSFive9Admin.contactFieldRestriction
            $restriction.typeSpecified = $true
            $restriction.value = $item

            if ($contactFieldToModify.restrictions.type -contains 'Multiset')
            {
                $restriction.type = 'Multiset'
            }
            else
            {
                $restriction.type = 'Set'
            }

            $contactFieldToModify.restrictions += $restriction
        }
    }


 
    return $Five9AdminClient.modifyContactField($contactFieldToModify)

}


