#!/bin/bash
# Local Chinese UI overlay for the manually installed Mole CLI.
# Only terminal-bound display output is translated; captured values, files,
# JSON, command arguments, and machine-readable output keep upstream text.

mole_zh_translate() {
    local text="${1:-}" pair source_text target_text
    local -a translations=(
        'Deep clean and optimize your Mac.|深度清理并优化你的 Mac。'
        'Free up disk space|释放磁盘空间'
        'Remove apps completely|彻底卸载应用'
        'Refresh caches and services|刷新缓存与系统服务'
        'Explore disk usage|查看磁盘占用'
        'Monitor system health|监控系统状态'
        'Review cleanup activity|查看清理记录'
        'Remove old project artifacts|清理项目构建残留'
        'Find and remove installer files|查找并删除安装包'
        'Remove Intel code from universal apps|移除通用应用中的 Intel 代码'
        'Configure Touch ID for sudo|为 sudo 配置触控 ID'
        'Setup shell tab completion|设置命令行自动补全'
        'Update to latest version|更新到最新版本'
        'Remove Mole from system|从系统中移除 Mole'
        'Main menu|主菜单'
        'Clean        Free up disk space|清理        释放磁盘空间'
        'Uninstall    Remove apps completely|卸载        彻底卸载应用'
        'Optimize     Refresh caches and services|优化        刷新缓存与系统服务'
        'Analyze      Explore disk usage|分析        查看磁盘占用'
        'Status       Monitor system health|状态        监控系统状态'
        'M More|M 更多'
        'V Version|V 版本'
        'U Update|U 更新'
        'Q Quit|Q 退出'
        'T TouchID|T 触控 ID'
        'V Version|V 版本'
        'U Update|U 更新'
        'Q Quit|Q 退出'
        'COMMANDS|命令'
        'OPTIONS|选项'
        'Usage:|用法：'
        'Options:|选项：'
        'Commands:|命令：'
        'Default Paths:|默认路径：'
        'Show help|显示帮助'
        'Show this help message|显示此帮助信息'
        'Show version|显示版本'
        'Show detailed operation logs|显示详细操作日志'
        'Export cleanup history|导出清理记录'
        'Enable debug logging|启用调试日志'
        'Preview cleanup|预览清理内容'
        'Preview optimization|预览优化内容'
        'Preview app uninstall|预览应用卸载内容'
        'Preview project purge|预览项目残留清理内容'
        'Preview installer cleanup|预览安装包清理内容'
        'Preview Intel code removal|预览 Intel 代码移除内容'
        'Preview Touch ID setup|预览触控 ID 设置'
        'Preview shell completion edits|预览命令行补全设置'
        'Preview Mole removal|预览 Mole 移除内容'
        'Manage protected caches|管理受保护的缓存'
        'Manage protected items|管理受保护的项目'
        'Manage protected paths|管理受保护的路径'
        'Configure scan directories|设置扫描目录'
        'Analyze external drives only|仅分析外接磁盘'
        'Force reinstall latest stable version|强制重新安装最新稳定版'
        'Install latest unreleased main branch build|安装 main 分支最新开发版本'
        'Preview cleanup without making changes|预览清理内容，不做任何更改'
        'Preview optimization without making changes|预览优化内容，不做任何更改'
        'Preview installer cleanup without making changes|预览安装包清理内容，不做任何更改'
        'Preview purge actions without making changes|预览清理操作，不做任何更改'
        'Preview Touch ID changes without modifying sudo config|预览触控 ID 设置，不修改 sudo 配置'
        'Clean up disk space by removing caches, logs, temporary files, and app leftovers from already-uninstalled apps.|清理缓存、日志、临时文件，以及已卸载应用的残留以释放磁盘空间。'
        'Interactively remove applications and their leftover files.|通过交互菜单卸载应用及其残留文件。'
        'Refresh system caches and services, repair safe maintenance issues.|刷新系统缓存与服务，并修复安全的维护问题。'
        'Find and remove installer files (.dmg, .pkg, .iso, .xip, .zip).|查找并删除安装包（.dmg、.pkg、.iso、.xip、.zip）。'
        'Enable Touch ID for sudo|为 sudo 启用触控 ID'
        'Disable Touch ID for sudo|为 sudo 关闭触控 ID'
        'Show current Touch ID status|查看触控 ID 状态'
        'If no command is provided, an interactive menu is shown.|如果未指定命令，将显示交互式菜单。'
        'Interactively remove applications and their leftover files.|通过交互菜单卸载应用及其残留文件。'
        'For leftovers from apps that are already gone, use mo clean.|清理已卸载应用的残留请使用 mo clean。'
        'Preview app uninstallation without making changes|预览应用卸载，不做任何更改'
        'By default, uninstalled files go to the macOS Trash so they can be|默认情况下，卸载的文件会移至 macOS 废纸篓，以便恢复。'
        'recovered. Use --permanent to skip the Trash step.|使用 --permanent 可跳过废纸篓。'
        'Clean Your Mac|清理 Mac'
        'Clean External Volume|清理外接磁盘'
        '━━━ External volume ━━━|━━━ 外接磁盘 ━━━'
        '━━━ System ━━━|━━━ 系统项目 ━━━'
        '━━━ User essentials ━━━|━━━ 用户常用项目 ━━━'
        '━━━ App caches ━━━|━━━ 应用缓存 ━━━'
        '━━━ Browsers ━━━|━━━ 浏览器 ━━━'
        '━━━ Cloud & Office ━━━|━━━ 云服务与办公软件 ━━━'
        '━━━ Developer tools ━━━|━━━ 开发工具 ━━━'
        '━━━ Apps & utilities ━━━|━━━ 应用与工具 ━━━'
        '━━━ Virtualization ━━━|━━━ 虚拟化软件 ━━━'
        '━━━ Application Support ━━━|━━━ 应用支持文件 ━━━'
        '━━━ App leftovers ━━━|━━━ 应用残留 ━━━'
        '━━━ Device backups & firmware ━━━|━━━ 设备备份与固件 ━━━'
        '━━━ Time Machine ━━━|━━━ 时间机器 ━━━'
        '━━━ Large files ━━━|━━━ 大文件 ━━━'
        '━━━ Project artifacts ━━━|━━━ 项目构建产物 ━━━'
        'Dry Run Mode|预览模式'
        'Preview only, no deletions|仅预览，不会删除文件'
        'Running in non-interactive mode|正在以非交互模式运行'
        'System-level cleanup enabled, sudo session active|已启用系统级清理，sudo 会话有效'
        'System-level cleanup skipped, requires sudo|已跳过系统级清理，需要 sudo 权限'
        'User-level cleanup will proceed automatically|将自动继续清理用户级项目'
        'Admin access available, system preview included|已有管理员权限，预览包含系统项目'
        'System caches need sudo, run|系统缓存需要 sudo，请运行'
        'Admin access already available|管理员权限已就绪'
        'Use --dry-run to preview, --whitelist to manage protected paths|使用 --dry-run 预览，使用 --whitelist 管理受保护路径'
        'Clean up project build artifacts|清理项目构建产物'
        'Purge Project Artifacts|清理项目构建产物'
        'Mole Purge|Mole 项目清理'
        'Select Artifacts to Purge|选择要清理的构建产物'
        'Edit custom scan directories|编辑自定义扫描目录'
        'Show zero-size project artifact directories|显示大小为零的项目构建目录'
        'Confirm unattended cleanup of eligible artifacts|确认自动清理符合条件的产物'
        'Unknown option:|未知选项：'
        'Unknown command:|未知命令：'
        'for usage information|查看用法说明'
        'Force reinstall latest stable version|强制重新安装最新稳定版'
        'latest stable version|最新稳定版'
        'unreleased main branch build|main 分支最新开发版'
        ' for usage.| 查看用法。'
        "Use '|请使用 '"
        "Run 'mo history --help' for usage.|运行 'mo history --help' 查看用法。"
        'Select Installers to Remove|选择要删除的安装包'
        'Select apps to slim|选择要精简的应用'
        'Select Apps to Remove|选择要卸载的应用'
        'No apps selected|未选择应用'
        'No items provided|没有可处理的项目'
        'Selected apps|已选应用'
        'Files to be removed|将要删除的文件'
        'Personal data kept|保留的个人数据'
        'Select the app again and review the new removal plan|请重新选择该应用并检查新的卸载方案'
        'Move it to Trash in Finder|请在访达中将其移到废纸篓'
        'Kept (protected by Mole)|已保留（受 Mole 保护）'
        'Uninstall complete|卸载完成'
        'Uninstall incomplete|卸载未完成'
        'Uninstall dry run complete|卸载预览完成'
        'Optimization Complete|优化完成'
        'Dry Run Complete, No Changes Made|预览完成，未做任何更改'
        'Would apply|将应用'
        'Run without|请去掉'
        'to apply these changes|以应用这些更改'
        'unchanged|未更改'
        'skipped|已跳过'
        ' unavailable| 不可用'
        ' need attention| 需要关注'
        ' failed| 失败'
        'databases optimized|个数据库已优化'
        'configs repaired|个配置已修复'
        'cache cleaned|缓存已清理'
        'Analyze Disk|磁盘分析'
        'Mole History|Mole 操作记录'
        'Selected paths:|已选择的路径：'
        'Press Enter to continue|按回车键继续'
        'Press Enter to continue, or Space to skip|按回车键继续，按空格跳过'
        'Press Enter to confirm|按回车键确认'
        'Press Enter to return to the app list, press q to exit|按回车键返回应用列表，按 q 退出'
        'Enter Confirm|回车确认'
        'Enter Apply|回车应用'
        'Space Select|空格选择'
        'Esc Clear filter|Esc 清除筛选'
        'Esc Back|Esc 返回'
        'Back|返回'
        'Select All|全选'
        'Invert|反选'
        'A All|A 全部'
        'Filter: type to match, Enter to apply, Esc to clear|筛选：输入内容匹配，回车应用，Esc 清除'
        'R Refresh|R 刷新'
        'O Open|O 打开'
        'P Preview|P 预览'
        'Del Delete|Del 删除'
        'Esc Cancel|Esc 取消'
        'Enter Confirm|回车确认'
        'Scanning |正在扫描 '
        'Analyzing |正在分析 '
        'Preparing |正在准备 '
        'Loading |正在加载 '
        'Removing |正在移除 '
        'Uninstalling |正在卸载 '
        'Installing |正在安装 '
        'Updating |正在更新 '
        'Scanning...|正在扫描……'
        'Loading...|正在加载……'
        'Unknown option:|未知选项：'
        'Unknown error|未知错误'
        'Disk Free:|磁盘可用空间：'
        'Free space:|可用空间：'
        'Architecture:|架构：'
        'Kernel:|内核：'
        'Install:|安装方式：'
        'Shell:|Shell：'
        'Channel:|更新通道：'
        'macOS:|macOS：'
        'SIP:|SIP：'
        'Mole version |Mole 版本 '
        'COMMANDS|命令'
        'Preview cleanup|预览清理内容'
        'Preview optimization|预览优化内容'
        'Preview app uninstall|预览应用卸载内容'
        'Cleanup complete|清理完成'
        'Cleanup incomplete|清理未完成'
        'Dry run cancelled|预览已取消'
        'Cleanup cancelled|清理已取消'
        'Dry run interrupted|预览已中断'
        'Cleanup interrupted|清理已中断'
        'Dry run incomplete|预览未完成'
        'Dry run complete - no changes made|预览完成，未做任何更改'
        'Test mode complete|测试模式已结束'
        'Test mode - no actual cleanup performed|测试模式：未执行实际清理'
        'Installers cleaned|安装包清理完成'
        'Installer cleanup incomplete|安装包清理未完成'
        'Slim complete|应用精简完成'
        'Slim incomplete|应用精简未完成'
        'Apps to slim:|要精简的应用：'
        'No apps were slimmed|没有精简任何应用'
        'No installers were removed|没有删除安装包'
        'No applications found to uninstall|未找到可卸载的应用'
        'No applications found for uninstallation|未找到可卸载的应用'
        'No applications available for uninstallation|没有可卸载的应用'
        'N/A (Steam-managed)|不适用（由 Steam 管理）'
        'Apple Silicon code missing|缺少 Apple Silicon 代码'
        'Gatekeeper check failed|Gatekeeper 检查失败'
        'Each app is slimmed on a copy that must pass code signing and Gatekeeper|每个应用会在副本上精简，并通过代码签名与 Gatekeeper 检查'
        'App Store app|App Store 应用'
        'Apple app|Apple 应用'
        'Removed:|已清理：'
        'Removed |已清理 '
        'Freed |释放 '
        ' items| 个项目'
        'Would remove|将删除'
        'Would clean|将清理'
        'No changes made|未做任何更改'
        'Press D to choose personal data|按 D 选择个人数据'
        'Select personal data|选择个人数据'
        'Choose personal data|选择个人数据'
        'Press D|按 D 键'
        'items selected|个项目已选'
        ' selected| 已选择'
        'No large files found|未找到大文件'
        'No results found|没有匹配结果'
        'Empty list|列表为空'
        'Nothing to clean|没有需要清理的内容'
        'Nothing to remove|没有需要移除的内容'
        'No items found|未找到项目'
        'Error:|错误：'
        'Warning:|警告：'
        'Failed:|失败：'
        'Unknown error|未知错误'
        'Permission denied|权限不足'
        'Operation cancelled|操作已取消'
        'Operation complete|操作完成'
        ' to confirm|确认'
        ' to cancel|取消'
        ' to quit|退出'
        ' to return|返回'
        ' to continue|继续'
        ' to skip|跳过'
    )

    for pair in "${translations[@]}"; do
        source_text="${pair%%|*}"
        target_text="${pair#*|}"
        text="${text//"$source_text"/$target_text}"
    done
    builtin printf '%s' "$text"
}

mole_zh_maybe_translate() {
    local rendered="$*" trigger
    local -a triggers=(
        Clean Uninstall Optimize Analyze Status History Purge Installer TouchID "Touch ID"
        COMMANDS OPTIONS Usage "Default Paths" "Main menu" "Free up disk space"
        "Remove apps completely" "Refresh caches" "Explore disk usage" "Monitor system health"
        "Review cleanup" "Remove old project" "Find and remove installer" "Remove Intel code"
        "Configure Touch ID" "Setup shell tab" "Update to latest" "Remove Mole"
        "Show help" "Show version" "Show this help" "Show detailed operation logs"
        "Export cleanup history" "Force reinstall" "latest stable" "Install latest"
        Preview "Dry Run" selected Selected Select
        Confirm Cancel Quit Back Open Refresh Scanning Analyzing Preparing Loading Removing
        Uninstalling Installing Updating Unknown Error Warning Failed Removed Freed "Would "
        "No " "Press " Disk "Free space" Architecture Kernel "Install:" "Shell:" "Channel:"
        "macOS:" "SIP:" System User Protected Skipped Complete items applications " files"
        " folders" cache Cache database config "Space Select" "Enter Confirm" "Enter Apply"
        "Esc " Mole apps files " paths" directories directory "without making changes"
        "to apply" "to confirm" "to cancel" "to quit" "to return" "to continue" "to skip"
    )
    for trigger in "${triggers[@]}"; do
        [[ "$rendered" == *"$trigger"* ]] && return 0
    done
    return 1
}

echo() {
    if [[ -n "${MOLE_ZH_DISABLE:-}" || ! -t 1 ]] || ! mole_zh_maybe_translate "$@"; then
        builtin echo "$@"
        return
    fi
    local rendered translated
    rendered="$(builtin echo "$@"; builtin printf '\001')"
    rendered="${rendered%$'\001'}"
    translated="$(mole_zh_translate "$rendered"; builtin printf '\001')"
    translated="${translated%$'\001'}"
    builtin printf '%s' "$translated"
}

printf() {
    if [[ -n "${MOLE_ZH_DISABLE:-}" || ! -t 1 ]] || ! mole_zh_maybe_translate "$@"; then
        builtin printf "$@"
        return
    fi
    local rendered translated rc=0
    rendered="$(builtin printf "$@" || rc=$?; builtin printf '\001')"
    rendered="${rendered%$'\001'}"
    translated="$(mole_zh_translate "$rendered"; builtin printf '\001')"
    translated="${translated%$'\001'}"
    builtin printf '%s' "$translated"
    return "$rc"
}
