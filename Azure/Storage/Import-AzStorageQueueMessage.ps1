function Import-AzStorageQueueMessage
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ConnectionString,

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string] $Path
    )

    $StorageContext = New-AzStorageContext -ConnectionString $ConnectionString
    $Queue          = Get-AzStorageQueue -Name $Name -Context $StorageContext

    [array] $Messages = Get-Content -Path $Path -Raw | ConvertFrom-Json

    $Messages | ForEach-Object {
        Write-Progress -Id 0 -Activity "Importing in queue '$Name'" -PercentComplete ([math]::round([math]::min(100, (100 * $Messages.IndexOf($_) / $Messages.Count)), 0))

        $Message = [Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new(($_ | ConvertTo-Json -Depth 10))
        $Queue.CloudQueue.AddMessage($Message) | Out-Null
    }

    Write-Progress -Id 0 -Activity "Importing in queue '$Name'" -Completed
}