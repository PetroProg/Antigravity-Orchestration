param(
    [string]$ProjectsRoot = "$HOME\projects",
    [switch]$SkipGlobalGitIgnore
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

# 1. Install global security-baseline plugin
$PluginDst = "$HOME\.gemini\config\plugins\security-baseline"
New-Item -ItemType Directory -Force -Path "$PluginDst\rules" | Out-Null
Copy-Item "$RepoRoot\plugins\security-baseline\plugin.json" "$PluginDst\plugin.json" -Force
Copy-Item "$RepoRoot\plugins\security-baseline\rules\AGENTS.md" "$PluginDst\rules\AGENTS.md" -Force
Write-Host "[OK] Installed security-baseline plugin -> $PluginDst"

# 2. Configure global gitignore for GEMINI.md and STATE.md
if (-not $SkipGlobalGitIgnore) {
    $GlobalIgnore = "$HOME\.gitignore_global"
    if (-not (Test-Path $GlobalIgnore)) { New-Item -ItemType File -Path $GlobalIgnore -Force | Out-Null }
    $content = Get-Content $GlobalIgnore -Raw -ErrorAction SilentlyContinue
    if ($content -notmatch "(?m)^GEMINI\.md\r?$") { Add-Content $GlobalIgnore "GEMINI.md" -Encoding UTF8 }
    if ($content -notmatch "(?m)^STATE\.md\r?$")  { Add-Content $GlobalIgnore "STATE.md" -Encoding UTF8 }
    git config --global core.excludesfile $GlobalIgnore
    Write-Host "[OK] Configured global gitignore -> $GlobalIgnore"
}

# 3. Initialize _control-plane if not present
$ControlPlane = Join-Path $ProjectsRoot "_control-plane"
if (-not (Test-Path $ControlPlane)) {
    New-Item -ItemType Directory -Force -Path "$ControlPlane\manifests", "$ControlPlane\generated-prompts" | Out-Null
    Copy-Item "$RepoRoot\templates\control-plane\GEMINI.md" "$ControlPlane\GEMINI.md"
    Copy-Item "$RepoRoot\templates\control-plane\PORTFOLIO.md" "$ControlPlane\PORTFOLIO.md"
    Copy-Item "$RepoRoot\templates\control-plane\.agents" "$ControlPlane\.agents" -Recurse -Force
    Write-Host "[OK] Initialized _control-plane -> $ControlPlane"
} else {
    Write-Host "[SKIP] _control-plane already exists -> $ControlPlane"
}
