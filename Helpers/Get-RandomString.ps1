function Get-RandomString
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('LowerCase', 'UpperCase', 'Numeric', 'Special')]
        [string[]] $Alphabet = @(
            'LowerCase',
            'UpperCase',
            'Numeric',
            'Special'
        ),

        [Parameter()]
        [int] $Length = 16,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $MinimumByAlphabet = 1
    )

    $AllAlphabets = @{
        LowerCase   = [char[]] 'abcdefghijklmnopqrstuvwxyz'
        UpperCase   = [char[]] 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        Numeric     = [char[]] '0123456789'
        Special     = [char[]] '-_/\^$*+=~&(){}[]@'
    }

    # First construct password from min alphabet count
    $MinChars = $MinimumByAlphabet * $Alphabet.Count
    $RandomString = @()

    for($i = 0; $i -lt $MinChars; $i++)
    {
        $RandomString += Get-Random -InputObject $AllAlphabets[$Alphabet[$i % $Alphabet.Count]]
    }

    # Fill randomly the rest
    for($i = $MinChars; $i -lt $Length; $i++)
    {
        $RandomString += Get-Random -InputObject $AllAlphabets[($Alphabet | Get-Random)]
    }

    ($RandomString | Sort-Object { Get-Random }) -join ''
}