function Invoke-FzfZoxide
{
    $ZoxideInstalled = $null -ne (Get-Command -Name zoxide -ErrorAction SilentlyContinue)

    if(-not $ZoxideInstalled)
    {
        throw "zoxide is not installed"
    }

    $HomePath = if($IsWindows)
    {
        $env:USERPROFILE
    }
    else
    {
        $env:HOME
    }

    $Selected = $null

    zoxide query -l |
        ForEach-Object { $_ -replace $HomePath, '~' } |
        Invoke-Fzf -NoSort |
        ForEach-Object {
            $Selected = $_
        }

    return $Selected
}
