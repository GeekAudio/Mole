import SwiftUI

struct OverviewView: View {
    let store: DashboardStore
    let openAnalysis: () -> Void
    let openTools: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PageHeader(title: "概览", subtitle: "查看 Mac 状态，并安全地开始维护。")

                if let error = store.refreshError {
                    InlineError(message: error)
                }

                if let snapshot = store.snapshot {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 14)], spacing: 14) {
                        MetricCard(
                            title: "处理器",
                            value: MoleDisplay.percent(snapshot.cpu?.usage),
                            detail: "\(snapshot.cpu?.logicalCpu ?? snapshot.cpu?.coreCount ?? 0) 个逻辑核心",
                            symbol: "cpu",
                            progress: snapshot.cpu?.usage,
                            tint: (snapshot.cpu?.usage ?? 0) > 85 ? .orange : .green
                        )
                        MetricCard(
                            title: "内存",
                            value: MoleDisplay.percent(snapshot.memory?.usedPercent),
                            detail: "已用 \(MoleDisplay.bytes(snapshot.memory?.used)) · 共 \(MoleDisplay.bytes(snapshot.memory?.total))",
                            symbol: "memorychip",
                            progress: snapshot.memory?.usedPercent,
                            tint: (snapshot.memory?.usedPercent ?? 0) > 88 ? .orange : .green
                        )
                        if let disk = snapshot.disks?.first(where: { $0.mount == "/" }) ?? snapshot.disks?.first {
                            MetricCard(
                                title: "启动磁盘",
                                value: MoleDisplay.percent(disk.usedPercent),
                                detail: "已用 \(MoleDisplay.bytes(disk.used)) · 共 \(MoleDisplay.bytes(disk.total))",
                                symbol: "internaldrive",
                                progress: disk.usedPercent,
                                tint: (disk.usedPercent ?? 0) > 90 ? .orange : .green
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("磁盘卷")
                                .font(.title3.weight(.semibold))
                            Spacer()
                            Text(snapshot.host ?? "Mac")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ForEach(Array((snapshot.disks ?? []).prefix(5))) { disk in
                            DiskUsageRow(disk: disk)
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                } else if store.isRefreshing {
                    ProgressView("正在读取系统状态…")
                        .frame(maxWidth: .infinity, minHeight: 180)
                } else {
                    ContentUnavailableView {
                        Label("尚无状态数据", systemImage: "waveform.path.ecg")
                    } description: {
                        Text("请刷新状态，或先安装 Mole 中文命令行版。")
                    } actions: {
                        Button("读取状态") { store.refresh() }
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, minHeight: 190)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("快速操作")
                        .font(.title3.weight(.semibold))
                    HStack(spacing: 12) {
                        QuickAction(title: "分析文件夹", symbol: "externaldrive", action: openAnalysis)
                        QuickAction(title: "查看清理预览", symbol: "doc.text.magnifyingglass", action: openTools)
                    }
                    Text("实际清理会在终端中显示项目并再次要求确认。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(24)
        }
    }
}

private struct QuickAction: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }
}
