# setup.ps1 — 建立 .claude/skills 与 .agents/skills 链接，让不同工具能加载 .cursor/skills 里的 skill
#
# 用法：
#   Windows:       powershell -ExecutionPolicy Bypass -File .\setup.ps1
#   macOS/Linux:   pwsh ./setup.ps1（需安装 PowerShell Core）
#
# 功能：
#   在项目根创建 .claude/skills 和 .agents/skills 链接，指向 .cursor/skills。
#   Windows 用 junction（免管理员权限），macOS/Linux 用符号链接。
#   幂等：目标链接已存在时直接跳过，可重复执行。
$ErrorActionPreference = 'Stop'

$root   = $PSScriptRoot
$target = Join-Path $root '.cursor\skills'

if (-not (Test-Path $target)) {
    Write-Host "[错误] 找不到目标目录: $target"
    exit 1
}

$dirs = @('.claude', '.agents')

foreach ($dirName in $dirs) {
    $parentDir = Join-Path $root $dirName
    $link      = Join-Path $parentDir 'skills'

    if (Test-Path $link) {
        Write-Host "[跳过] 已存在: $link"
        continue
    }

    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir | Out-Null
        Write-Host "[创建] $parentDir"
    }

    if ($env:OS -eq 'Windows_NT') {
        # Windows：junction，无需管理员权限
        $savedEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $null = cmd /c mklink /J "$link" "$target" 2>&1
        $code = $LASTEXITCODE
        $ErrorActionPreference = $savedEAP
        if ($code -ne 0) {
            Write-Host "[错误] 创建链接失败: $link（退出码 $code）"
            continue
        }
    } else {
        # macOS / Linux：符号链接
        New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    }

    Write-Host "[完成] $link -> $target"
    Get-ChildItem $link | ForEach-Object { Write-Host "  skill: $($_.Name)" }
}
