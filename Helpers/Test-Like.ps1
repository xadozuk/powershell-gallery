function Test-Like
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
                $object -like $_
            }

            Write-Output ($TestResults -contains $true)
        }
    }
}
