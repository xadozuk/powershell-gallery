function Open-TmuxSession
{
  [CmdletBinding()]
  param(
    [Parameter()]
    [string[]] $Paths = @(
      '~/development/project'
      '~/development/my'
    )
  )

  $HomePath = if($IsWindows) { $env:USERPROFILE }
              else { $env:HOME }

  $ZoxideInstalled = $null -ne (Get-Command -Name zoxide -ErrorAction SilentlyContinue)
  $ScorePaths = @{}

  if($ZoxideInstalled)
  {
    $ZoxidePaths = zoxide query -l -s
    foreach($Path in $ZoxidePaths)
    {
      $Parts = $Path -split " " | Where-Object { -not [string]::IsNullOrEmpty($_) }
      $ScorePaths[$Parts[1]] = [float]$Parts[0]
    }
  }

  $Selected = Get-ChildItem -Path $Paths -Directory `
    | Foreach-Object {
        $Score = if($ScorePaths.ContainsKey($_.FullName)) { $ScorePaths[$_.FullName] }
                 else { 0 }

        [PSCustomObject] @{
          FullName = $_.FullName -replace $HomePath, '~'
          Score = $Score
          Debug = "$($Score): $($_.FullName)"
        }
      } `
    | Sort-Object -Property Score -Descending
    | Select-Object -ExpandProperty FullName `
    | Invoke-Fzf -NoSort

  if($null -eq $Selected) { return }

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
