# newspaper

## 在新机器上使用本仓库的 skill（cline）

本仓库把三个 skill（`weekly-report`、`monthly-report`、`prototype-analysis`）存放在 `.cursor/skills/`（唯一来源）。
cline 通过项目级 `.claude/skills/` 加载它们，该目录是链接，**不进版本库**。

克隆后运行一次即可：

- Windows：`powershell -ExecutionPolicy Bypass -File .\setup.ps1`
- macOS/Linux：`pwsh ./setup.ps1`

然后**新开一个 cline 会话**即可在 skill 列表里看到这三个 skill。

