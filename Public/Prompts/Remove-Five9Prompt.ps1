function Remove-Five9Prompt
{
    <#
    .SYNOPSIS
    
        Function used to delete a prompt in Five9

    .EXAMPLE

        Remove-Five9Prompt -Name 'Greeting'

        # Removes prompt named 'Greeting'

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of prompt to be removed
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing prompt '$Name'." 
        return $global:DefaultFive9AdminClient.deletePrompt($Name)

    }
    catch
    {
        throw $_
    }
}
