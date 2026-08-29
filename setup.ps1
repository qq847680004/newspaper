# setup.ps1 — 建立 .claude/skills 链接，让 cline 能加载 .cursor/skills 里的 skill
#
# 用法：
#   Windows:       powershell -ExecutionPolicy Bypass -File .\setup.ps1
#   macOS/Linux:   pwsh ./setup.ps1（需安装 PowerShell Core）
#
# 功能：
#   在项目根创建 .claude/skills 链接，指向 .cursor/skills。
#   Windows 用 junction（免管理员权限），macOS/Linux 用符号链接。
#   幂等：.claude/skills 已存在时直接跳过，可重复执行。
$ErrorActionPreference = 'Stop'

$root   = $PSScriptRoot
$link   = Join-Path $root '.claude\skills'
$target = Join-Path $root '.cursor\skills'

if (Test-Path $link) {
    Write-Host "[跳过] 已存在: $link"
    exit 0
}

if (-not (Test-Path $target)) {
    Write-Host "[错误] 找不到目标目录: $target"
    exit 1
}

$claudeDir = Join-Path $root '.claude'
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
    Write-Host "[创建] $claudeDir"
}

if ($env:OS -eq 'Windows_NT') {
    # Windows：junction，无需管理员权限
    cmd /c mklink /J "$link" "$target"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[错误] 创建链接失败"
        exit 1
    }
} else {
    # macOS / Linux：符号链接
    New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
}

Write-Host "[完成] $link -> $target"
Get-ChildItem $link | ForEach-Object { Write-Host "  skill: $($_.Name)" }
