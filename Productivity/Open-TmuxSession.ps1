function Open-TmuxSession
{
    [CmdletBinding()]
    param()

    $Selected = Invoke-FzfZoxide

    if($null -eq $Selected)
    {
        Write-Verbose "No folder selected"
        return
    }

    $SelectedName = Get-Item -Path $Selected | Select-Object -ExpandProperty Name

    Write-Verbose "Selected folder: $Selected"
    Write-Verbose "Session name: $SelectedName"

    $TmuxRunning = $null -ne (Get-Process -Name "tmux: server" -ErrorAction SilentlyContinue)
    $InsideTmux = $null -ne $env:TMUX

    Write-Verbose "Tmux already running ? $TmuxRunning"
    Write-Verbose "Inside tmux ? $InsideTmux"

    if(-not $InsideTmux -and -not $TmuxRunning)
    {
        tmux new-session -s $SelectedName -c $Selected
        return
    }

    tmux has-session -t="$SelectedName" 2>&1 > $null
    $TmuxHasSession = $LASTEXITCODE -eq 0

    Write-Verbose "Session already running ? $TmuxHasSession"

    if(-not $TmuxHasSession)
    {
        tmux new-session -ds $SelectedName -c $Selected
    }
    elseif(-not $InsideTmux)
    {
        tmux attach-session -t $SelectedName
    }
    else
    {
        tmux switch-client -t $SelectedName
    }
}
