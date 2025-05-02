#requires -Version 5.1
<#
  pre-commit.ps1 – Git hook that:
   1) loads cleaner-config.json from the repo root,
   2) collects staged files (with allowed extensions),
   3) creates a backup of each file,
   4) removes tagged comments (e.g. //#PL: ... #/),
   5) removes empty comment blocks,
   6) skips lines that are empty after comment removal,
   7) updates the staged version, restores the original locally.
#>

# Load cleaner-config.json
$repoRoot   = git rev-parse --show-toplevel
$configPath = Join-Path $repoRoot 'cleaner-config.json'

if (-not (Test-Path $configPath)) {
    Write-Error "Missing cleaner-config.json in the repository root. Commit aborted."
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json

# Prepare extension match regex
$extPattern = '\.(' + ($config.extensions -join '|') + ')$'

# Get staged files matching the extensions
$files = git diff --cached --name-only --diff-filter=ACM |
    Where-Object { $_ -match $extPattern }

foreach ($file in $files) {
    $absFilePath = Join-Path $repoRoot $file
    $backup = "$absFilePath.backup"
    $temp   = "$absFilePath.temp"

    # Ensure folder exists
    $null = New-Item -ItemType Directory -Path (Split-Path $backup) -Force

    # Backup the original file
    Copy-Item $absFilePath $backup -Force
    $content = Get-Content $absFilePath -Raw

    # Remove tagged comments
    foreach ($pat in $config.tagPatterns) {
        $content = $content -replace $pat, ''
    }

    # Remove empty comment blocks
    foreach ($pat in $config.emptyCommentPatterns) {
        $content = $content -replace $pat, ''
    }

    # Remove lines that are empty and were originally tagged comments
    $lines         = $content -split "`r?`n"
    $originalLines = (Get-Content $absFilePath -Raw) -split "`r?`n"
    $filtered      = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $originalLine = $originalLines[$i]
        $newLine      = $lines[$i]

        if ($originalLine -match ($config.tagPatterns -join '|') -and [string]::IsNullOrWhiteSpace($newLine)) {
            continue
        }
        $filtered += $newLine
    }

    $cleanedContent = $filtered -join "`r`n"

    # Save cleaned version to temp file and update staged version
    Set-Content -Path $temp -Value $cleanedContent
    $hash = git hash-object -w $temp
    git update-index --cacheinfo 100644,$hash,$file
    Remove-Item $temp -Force

    # Restore the original file locally
    Copy-Item $backup $absFilePath -Force
    git add $file
    Remove-Item $backup -Force

    Write-Host "✔ Cleaned: $file"
}
