# Mole 中文版 macOS App

这是 Mole 中文命令行版的轻量桌面入口，支持 macOS 14 或更高版本，提供系统状态、文件夹分析和清理预览。实际清理、优化与项目清理会在 Terminal 中运行原有 Mole 命令，并保留其确认流程。

## 使用

先安装仓库根目录 README 中的 Mole 中文命令行版，然后打开 `Mole 中文版.app`。App 会调用 `~/.local/bin/mole`，也会查找 Homebrew 的常用安装路径。

## 构建

```bash
bash scripts/build-app.sh
bash scripts/build-app.sh --universal --output /tmp/mole-app
```

通用构建会生成 Intel 与 Apple 芯片均可运行的 App，并打包为 `Mole-zh-macOS-universal.zip`。构建使用临时签名，当前未进行 Apple Developer ID 公证；从网络下载后，macOS 可能要求在“隐私与安全性”中手动允许首次打开。

本 App 依据仓库根目录的 GNU 通用公共许可证第三版发布。
