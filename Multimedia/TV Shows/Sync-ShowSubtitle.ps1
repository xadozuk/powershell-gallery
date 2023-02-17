function Sync-ShowSubtitle
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path = (Get-Location),

        [Parameter()]
        [string] $FileExtension = 'mkv',

        [Parameter()]
        [string] $Lang = 'en'
    )

    Write-Verbose "Searching files in '$Path'"

    $ShowFiles = Get-ChildItem -Path $Path -Filter "*.$FileExtension"
    Write-Verbose "Found $($ShowFiles.Count) show files"

    $SubtitleFiles = Get-ChildItem -Path $Path -Filter "*.srt"
    Write-Verbose "Found $($SubtitleFiles.Count) subtitle files"

    foreach($file in $SubtitleFiles)
    {
        if($file.Name -inotmatch "[0-9]{1,2}[ex]([0-9]{2})")
        {
            Write-Verbose "Unable to find related episode for subtitle '$($file.Name)'"
            continue
        }

        $RefToEpisode = $Matches[1]
        Write-Verbose "Subtitle '$($file.Name)' related to episode $RefToEpisode"

        $EpisodeFile = $ShowFiles | Where-Object { $_.Name -imatch "[0-9]{1,2}[ex]$RefToEpisode" }

        if($null -eq $EpisodeFile)
        {
            Write-Warning "Unable to find episode $RefToEpisode"
            continue
        }

        Move-Item -Path $file.FullName -Destination ($EpisodeFile.FullName -replace ".$FileExtension", ".$Lang.srt")
    }
}