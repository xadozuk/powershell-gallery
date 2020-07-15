function Watch-AzResourceGroupDeployment
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ResourceGroupName,

        [Parameter()]
        [switch] $HideSucceded
    )

    Watch-Command -Wait 5 -ScriptBlock {
        $Operations = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
            | Get-AzResourceGroupDeploymentOperation `
            | Select-Object -ExpandProperty Properties
        
        if($HideSucceded)
        {
            $Operations = $Operations | Where-Object provisioningState -ne "Succeeded"
        }

        if($Operations.Count -eq 0)
        {
            Write-Warning "No operations remaining on deployment in resource group '$ResourceGroupName'."
        }
        else
        {
            $Operations | Select-Object `
                @{n="Timestamp";e={ [datetime] $_.Timestamp }},
                @{n="Operation";e={ $_.provisioningOperation }},
                @{n="State";e={ $_.provisioningState }},
                @{n="ResourceType";e={ $_.targetResource.resourceType }},
                @{n="ResourceName";e={ $_.targetResource.resourceName }} `
                | Format-Table
                | Out-String
                | Write-Output
        }        
    }
}