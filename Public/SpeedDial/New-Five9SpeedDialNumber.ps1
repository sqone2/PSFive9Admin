function New-Five9SpeedDialNumber
{
    <#
    .SYNOPSIS
    
        Function used to create a new speed dial number
   
    .EXAMPLE
    
        New-Five9SpeedDialNumber -Code 5 -Number 6154569101 -Description "Nashville Office"
    
        # Creates a new speed dial number
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Code assigned to the telephone number to speed dial
        [Parameter(Mandatory=$true)][string]$Code,
        # Telephone number to dial
        [Parameter(Mandatory=$true)][string]$Number,
        # Description for the number
        [Parameter(Mandatory=$false)][string]$Description
    )
    
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new speed dial number. Code: '$Code' Number: '$Number'." 
        return $global:DefaultFive9AdminClient.createSpeedDialNumber($Code,$Number,$Description)

    }
    catch
    {
        throw $_
    }
}