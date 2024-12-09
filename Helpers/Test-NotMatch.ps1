function Test-NotMatch
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $InputObject,

        [Parameter(Mandatory)]
        [string[]] $In
    )

    process
    {
        $InputObject | Test-Match -In $In | ForEach-Object { -not $_ }
    }
}
