function Write-PSFive9AdminError 
{
    <#
    .SYNOPSIS
    
        Function used by PSFive9Admin to write custom error messages

    .EXAMPLE
    
        $_ | Write-PSFive9AdminError 
    
        # Pass caught expection to fucntion
    
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)][object]$Exception
    )

    if ($Exception.Exception.Message -match 'You are not currently connected to the Five9 Admin Web Service')
    {
        throw $Exception
    }
    elseif ($Exception.Exception.Message -match 'You are not currently connected to the Five9 Statistics Web Service')
    {
        throw $Exception
    }
    elseif ($Exception.Message -match 'Session was closed')
    {
        throw "Your statistics session has expired. Please reconnect using Connect-Five9Statistics."
    }
}