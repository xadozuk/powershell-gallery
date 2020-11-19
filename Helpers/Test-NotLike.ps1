function Test-NotLike
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
        $InputObject | Test-Like -In $In
    }
}
