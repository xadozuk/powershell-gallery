function Watch-Command
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0)]
        [scriptblock] $ScriptBlock,

        [Parameter()]
        [int] $Wait = 1
    )
    
    while($true)
    {
        $Output = &$ScriptBlock

        Clear-Host

        Write-Host "$(Get-Date -format "dd/MM/yyyy HH:mm:ss")`nEvery $($Wait)s"
        $Output | Write-Host

        Start-Sleep -Seconds $Wait
    }
}