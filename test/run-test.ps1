# run-test.ps1 – verifies that comment cleaning works correctly

$ErrorActionPreference = "Stop"

$root = Split-Path $MyInvocation.MyCommand.Path -Parent
$projectRoot = Join-Path $root ".."
$configPath = Join-Path $projectRoot "cleaner-config.json"
$config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

$outputDir = Join-Path $root "output"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$inputFiles = Get-ChildItem $root -Filter "example_input.*"
$failed = 0

foreach ($file in $inputFiles) {
    $ext = $file.Extension
    $inputContent = Get-Content $file.FullName -Raw -Encoding UTF8

    # Remove tagged comments
    foreach ($pat in $config.tagPatterns) {
        $inputContent = $inputContent -replace $pat, ''
    }

    # Remove empty comments
    foreach ($pat in $config.emptyCommentPatterns) {
        $inputContent = $inputContent -replace $pat, ''
    }

    # Remove lines that were originally comments and are now empty
    $linesIn  = (Get-Content $file.FullName -Raw -Encoding UTF8) -split "`r?`n"
    $linesOut = $inputContent -split "`r?`n"
    $result = @()
    for ($i = 0; $i -lt $linesOut.Count; $i++) {
        if ($linesIn[$i] -match ($config.tagPatterns -join '|') -and [string]::IsNullOrWhiteSpace($linesOut[$i])) {
            continue
        }
        $result += $linesOut[$i]
    }
    $cleaned = $result -join "`r`n"

    # Save actual output to file
    $outPath = Join-Path $outputDir ($file.Name -replace "example_input", "actual_output")
    Set-Content -Path $outPath -Value $cleaned -Encoding UTF8

    # Compare trimmed, meaningful lines (ignoring whitespace-only differences)
    $actualNormalized   = ($cleaned -split "`r?`n" | Where-Object { $_.Trim() -ne "" }) -join "`n"
    $expectedPath       = $file.FullName -replace "example_input", "expected_output"
    $expectedRaw        = Get-Content $expectedPath -Raw -Encoding UTF8
    $expectedNormalized = ($expectedRaw -split "`r?`n" | Where-Object { $_.Trim() -ne "" }) -join "`n"

    if ($actualNormalized -ne $expectedNormalized) {
        Write-Host " FAIL: $($file.Name)" -ForegroundColor Red
        $diff = Compare-Object ($expectedRaw -split "`r?`n") ($cleaned -split "`r?`n") -SyncWindow 2 -IncludeEqual:$false
        $diff | Format-Table -AutoSize
        Write-Host " Output saved to: $outPath" -ForegroundColor DarkGray
        $failed++
    } else {
        Write-Host " PASS: $($file.Name)" -ForegroundColor Green
    }
}

if ($failed -eq 0) {
    Write-Host "`n All tests passed!"
    exit 0
} else {
    Write-Host "`n $failed test(s) failed."
    exit 1
}
