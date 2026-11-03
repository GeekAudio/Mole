# Mole 中文版

Mole 是 macOS 命令行维护工具，可清理缓存与应用残留、卸载应用、整理系统服务、分析磁盘空间，并实时查看系统状态。本仓库在上游项目基础上提供简体中文界面。

## 功能

- 清理系统缓存、应用日志、临时文件和已卸载应用的残留
- 卸载应用并检查相关支持文件
- 交互式浏览磁盘占用和大文件
- 刷新 DNS、快速查看和图标缓存等系统服务
- 查看 CPU、内存、磁盘、网络、电池与进程状态
- 预览清理操作，查看历史记录

## 安装

需要 macOS 12 或更高版本，支持 Intel 和 Apple 芯片。

```bash
curl -fsSL https://raw.githubusercontent.com/GeekAudio/Mole/main/install.sh | bash -s -- --prefix "$HOME/.local/bin"
```

确保 `~/.local/bin` 已加入 `PATH`。安装完成后运行 `mo` 打开菜单。

## macOS 图形界面

先安装上方的中文命令行版，再从 [GitHub Releases](https://github.com/GeekAudio/Mole/releases/latest/download/Mole-zh-macOS-universal.zip) 下载并解压 `Mole 中文版.app`，拖入“应用程序”即可。图形界面提供系统状态、文件夹分析和清理预览；实际清理与优化会在终端中继续，并保留 Mole 原有的逐项确认流程。

此 App 使用临时签名，尚未进行 Apple Developer ID 公证。若 macOS 首次拦截，请在“系统设置 → 隐私与安全性”中允许打开。

## 常用命令

```bash
mo                  # 打开交互菜单
mo clean             # 清理缓存与应用残留
mo uninstall         # 卸载应用
mo optimize          # 刷新系统缓存与服务
mo analyze           # 浏览磁盘占用
mo status            # 查看实时系统状态
mo purge             # 清理项目构建产物
mo installer         # 查找安装包
mo history           # 查看操作记录
mo --help            # 查看帮助
```

涉及删除的命令可先使用 `--dry-run` 预览：

```bash
mo clean --dry-run
mo uninstall --dry-run
mo purge --dry-run
```

## 安全说明

Mole 会校验待处理路径，并保护系统目录与共享数据。日常使用不需要管理员权限；只有处理系统级项目时才会按需请求授权。卸载和磁盘分析中的删除操作会先要求确认，默认移入废纸篓。清理、项目产物和安装包操作可能永久删除文件，请先预览并确认清单。

操作记录保存在 `~/Library/Logs/mole/operations.log`，可用 `mo history` 查看。

## 上游项目

本项目基于 [tw93/Mole](https://github.com/tw93/Mole)，遵循 GNU 通用公共许可证第三版。感谢上游作者及贡献者。
