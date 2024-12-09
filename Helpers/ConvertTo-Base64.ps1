function ConvertTo-Base64
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position=0)]
        [string[]] $InputObject,

        [Parameter()]
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    )

    process {
        foreach($String in $InputObject)
        {
            Write-Output ([System.Convert]::ToBase64String($Encoding.GetBytes($String)))
        }
    }
}