function Export-AzStorageQueue
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ConnectionString,

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter()]
        [switch] $Purge,

        [Parameter()]
        [switch] $Force
    )

    $StorageContext = New-AzStorageContext -ConnectionString $ConnectionString
    $Queue          = Get-AzStorageQueue -Name $Name -Context $StorageContext

    $MessageCount = $Queue.CloudQueue.ApproximateMessageCount

    # We count 100ms per message (maybe a bit large)
    $InvisibilityTimeout = [System.TimeSpan]::FromSeconds($MessageCount * 0.1)
    $AllMessages = 0

    if((Test-Path -Path $Path) -and -not $Force)
    {
        throw "File '$Path' already exists. Use -Force to overwrite."
    }

    $TempFolderName = "AzStorageQueue-$Name-$(Get-Date -Format "yyyyMMddHHmmssff")"
    $TempPath = New-Item -ItemType Directory -Name $TempFolderName -Path $env:TEMP

    while($true)
    {
        Write-Progress -Id 0 -Activity "Exporting queue '$Name'" -PercentComplete ([math]::round([math]::min(100, (100 * $AllMessages / $MessageCount)), 0))

        $Messages = $Queue.CloudQueue.GetMessagesAsync(32, $InvisibilityTimeout, $null, $null)
        $Results = $Messages.Result

        if($Results.Count -eq 0) 
        { 
            Write-Verbose "No messages left in queue"
            break 
        }

        # Should persist message directly to disk
        $AllMessages += $Results.Count

        $Results | ForEach-Object {
            $_.AsString | Out-File -FilePath "$($TempPath.FullName)\$($_.ID).json"
        }

        if($Purge)
        {
            $Results | ForEach-Object {
                $Queue.CloudQueue.DeleteMessageAsync($_.Id, $_.PopReceipt)
            }
        }
    }

    Write-Progress -Id 0 -Activity "Exporting queue '$Name'" -Completed

    # TODO: consolidate everything
    Write-Verbose "Consolidating files..."

    $Objects = @()

    Get-ChildItem -Path $TempPath -Filter "*.json" | ForEach-Object {
        $Objects += $_ | Get-Content -Raw | ConvertFrom-Json
    }

    $Objects | ConvertTo-Json -Depth 10 -Compress | Out-File -Encoding UTF8 -FilePath $Path -Force

    Remove-Item -Path $TempPath -Recurse -Force
}