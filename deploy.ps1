# deploy.ps1 - auto-stamp a version and deploy to GitHub Pages.
# Usage:  .\deploy.ps1              (default commit message)
#         .\deploy.ps1 "message"    (custom commit message)
# Steps: make a fresh version from the current time -> sync index.html BUILD and
#        version.txt -> git commit -> git push. Old phones auto-reload to the new build.
# NOTE: keep this file ASCII-only (Windows PowerShell 5.1 mis-decodes non-ASCII .ps1).
param([string]$m = "update")

$ErrorActionPreference = "Stop"

# Find the folder that actually contains index.html (invocation vars may be empty).
$root = $null
$cands = @(
  $PSScriptRoot,
  $(if ($PSCommandPath) { Split-Path -Parent $PSCommandPath } else { $null }),
  $(if ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $null }),
  (Get-Location).Path
)
foreach ($c in $cands) {
  if ($c -and (Test-Path (Join-Path $c "index.html"))) { $root = $c; break }
}
if (-not $root) { throw "index.html not found. Run this inside the game folder." }
Set-Location -Path $root

# Version stamp with seconds so every run is unique (and never an empty commit).
$ver = Get-Date -Format "yyyy-MM-dd.HHmmss"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# version.txt (no trailing newline, no BOM)
[System.IO.File]::WriteAllText((Join-Path $root "version.txt"), $ver, $utf8NoBom)

# index.html: replace the BUILD constant, write back without BOM.
$idx = Join-Path $root "index.html"
$html = Get-Content $idx -Raw -Encoding UTF8
$html = $html -replace "const BUILD='[^']*'", "const BUILD='$ver'"
[System.IO.File]::WriteAllText($idx, $html, $utf8NoBom)

git add index.html version.txt
git commit -m "$m (build $ver)"
git push origin main

Write-Host ""
Write-Host "Deployed build $ver" -ForegroundColor Green
Write-Host "Live in ~1-2 min: https://tmk4men.github.io/edo-bashiri/"
