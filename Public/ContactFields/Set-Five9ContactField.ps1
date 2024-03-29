function Set-Five9ContactField
{
    <#
    .SYNOPSIS
    
        Function used to modify an existing contact field

    .NOTES

        • All campaigns must be stopped before modifying a contact field

    .EXAMPLE
        Set-Five9ContactField -Name 'hair_color' -DisplayAs Long

        # Modifies DisplayAs property on contact field 'hair_color'

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of contact field being modified
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        <#
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
        #>
        [Parameter(Mandatory=$false)][ValidateSet('None','LastDisposition','LastSystemDisposition','LastAgentDisposition','LastDispositionDateTime','LastSystemDispositionDateTime','LastAgentDispositionDateTime','LastAttemptedNumber','LastAttemptedNumberN1N2N3','LastCampaign','AttemptsForLastCampaign','LastList','CreatedDateTime','LastModifiedDateTime')][string]$MapTo,
        
        <#
        Display options for the data in the Agent desktop

        Options are:
            • Short (Default) - Half line
            • Long - Full line
            • Invisible - Not represented
        #>
        [Parameter(Mandatory=$false)][ValidateSet('Short', 'Long', 'Invisible')][string]$DisplayAs
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $contactFieldToModify = $null
        try
        {
            $contactFieldToModify = $global:DefaultFive9AdminClient.getContactFields($Name)
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

        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying contact field '$Name'." 
        return $global:DefaultFive9AdminClient.modifyContactField($contactFieldToModify)


    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}

