function ConvertFrom-Base64
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position=0)]
        [string[]] $InputObject,

        [Parameter()]
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    )

    process {
        foreach($Base64String in $InputObject)
        {
            Write-Output ($Encoding.GetString([System.Convert]::FromBase64String($Base64String)))
        }
    }
}