function Test-Match
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
        foreach($object in $InputObject)
        {
            $TestResults = $In | ForEach-Object {
                $object -match $_
            }

            Write-Output ($TestResults -contains $true)
        }
    }
}
