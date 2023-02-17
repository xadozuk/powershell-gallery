function Watch-AzAutomationJobOutput
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ResourceGroup,

        [Parameter(Mandatory)]
        [string] $AutomationAccount,

        [Parameter(Mandatory, ParameterSetName="ById")]
        [string] $Id,

        [Parameter(Mandatory, ParameterSetName="Latest")]
        [string] $Runbook,

        [Parameter(Mandatory, ParameterSetName="Latest")]
        [switch] $Latest
    )

    if($Latest)
    {
        $LastJob = Get-AzAutomationJob `
            -ResourceGroupName $ResourceGroup `
            -AutomationAccountName $AutomationAccount `
            -RunbookName $Runbook `
            | Sort-Object -Descending CreationTime `
            | Select-Object -First 1

        $Id = $LastJob.JobId

        Write-Verbose "Watching output for job '$Id'..."
    }

    $StartDate = $null

    $ColorMapping = @{
        Verbose     = "Cyan"
        Error       = "Red"
        Warning     = "Yellow"
        Output      = "White"
        Progess     = "Magenta"
    }

    while($true)
    {
        Get-AzAutomationJobOutput -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount -Id $Id -Stream Any -StartTime $StartDate `
        | Foreach-Object { 
            Write-Host "[$($_.Type.ToUpper())] $($_.Summary)" -ForegroundColor $ColorMapping[$_.Type]
        }

        $StartDate = Get-Date
        Start-Sleep -Seconds 3
    }

    
}