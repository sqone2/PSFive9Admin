function Get-Five9Prompt
{
    <#
    .SYNOPSIS
    
        Function used to return prompt(s)

    .EXAMPLE

        Get-Five9Prompt

        # Returns list of all prompts

    .EXAMPLE

        Get-Five9Prompt -Name 'Greeting'

        # Returns prompt named 'Greeting'

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of prompt to be returned
        # If omitted, all prompts will be returned
        [Parameter(Mandatory=$false)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        if ($PSBoundParameters.Keys -contains "Name")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning prompt '$Name'." 
            return $global:DefaultFive9AdminClient.getPrompt($Name)
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning all prompts." 
            return $global:DefaultFive9AdminClient.getPrompts()
        }

    }
    catch
    {
        throw $_
    }
}
