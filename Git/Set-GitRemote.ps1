function Set-GitRemote
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("AzureDevOps")]
        [string] $Type,

        [Parameter(Mandatory)]
        [ValidateSet("HTTPS", "SSH")]
        [string] $Protocol,

        [Parameter()]
        [string] $Remote = "origin"
    )

    $RemoteUrl = &git remote get-url $Remote 2>$null

    if($LASTEXITCODE -ne 0)
    {
        throw "Remote '$Remote' doesn't exists."
    }

    # Azure DevOps
    if($RemoteUrl -like "*dev.azure.com*")
    {
        $RemoteUrlParts = ($RemoteUrl -replace 'https://', '') -split '/'
        $Organization = $RemoteUrlParts[1]
        $Project      = $RemoteUrlParts[2]
        $Repository   = $RemoteUrlParts[-1]

        Write-Verbose "Found Azure DevOps remote: Org=$Organization, Proj=$Project, Repo=$Repository"

        $NewRemoteUrl = switch($Protocol)
        {
            "HTTPS" {
                "https://$Organization@dev.azure.com/$Organization/$Project/_git/$Repository"
            }

            "SSH" {
                "git@ssh.dev.azure.com:v3/$Organization/$Project/$Repository"
            }

            default {
                throw "Not implemented"
            }
        }

        Write-Verbose "New remote URL is: $NewRemoteUrl"

        if($PSCmdlet.ShouldProcess($Remote, "set-url $NewRemoteUrl"))
        {
            &git remote set-url $Remote $NewRemoteUrl
        }
    }
    else
    {
        throw "Not implemented"
    }
}