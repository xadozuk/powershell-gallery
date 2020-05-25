function Watch-AzStorageQueueStatistics
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ConnectionString,

        [Parameter(Mandatory)]
        [string[]] $Name
    )

    $StorageContext = New-AzStorageContext -ConnectionString $ConnectionString

    $LastMessageCount          = @{}
    $LastMessageCountTimestamp = @{}

    Watch -Wait 3 -ScriptBlock {
        $QueueStats = $Name | Foreach-Object {
            $Queue = Get-AzStorageQueue -Name $_ -Context $StorageContext

            if($null -ne $LastMessageCount[$_])
            {
                $DeltaMessage = $Queue.CloudQueue.ApproximateMessageCount - $LastMessageCount[$_]
                $DeltaMessagePerSec = [math]::Round($DeltaMessage / ((Get-Date).Subtract($LastMessageCountTimestamp[$_]).TotalSeconds), 2)
            }

            $LastMessageCount[$_] = $Queue.CloudQueue.ApproximateMessageCount
            $LastMessageCountTimestamp[$_] = Get-Date

            [PSCustomObject] @{
                Queue               = $_
                MessageCount        = $Queue.CloudQueue.ApproximateMessageCount
                DeltaMessagePerSec  = $DeltaMessagePerSec
            }
        }

        Write-Output ($QueueStats | Out-String)
    }.GetNewClosure()
}