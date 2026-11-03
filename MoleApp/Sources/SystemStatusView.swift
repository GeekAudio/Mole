import SwiftUI

struct SystemStatusView: View {
    let store: DashboardStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PageHeader(title: "系统状态", subtitle: "Mole 按需采集本机指标，不在后台持续监控。")

                if let error = store.refreshError {
                    InlineError(message: error)
                }

                if let snapshot = store.snapshot {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 14)], spacing: 14) {
                        MetricCard(
                            title: "CPU 使用率",
                            value: MoleDisplay.percent(snapshot.cpu?.usage),
                            detail: "\(snapshot.cpu?.coreCount ?? 0) 个核心 · \(snapshot.cpu?.logicalCpu ?? 0) 个逻辑处理器",
                            symbol: "cpu",
                            progress: snapshot.cpu?.usage,
                            tint: (snapshot.cpu?.usage ?? 0) > 85 ? .orange : .green
                        )
                        MetricCard(
                            title: "内存使用率",
                            value: MoleDisplay.percent(snapshot.memory?.usedPercent),
                            detail: "可用 \(MoleDisplay.bytes(snapshot.memory?.available))",
                            symbol: "memorychip",
                            progress: snapshot.memory?.usedPercent,
                            tint: (snapshot.memory?.usedPercent ?? 0) > 88 ? .orange : .green
                        )
                        MetricCard(
                            title: "运行时间",
                            value: snapshot.uptime ?? "—",
                            detail: "当前运行进程：\(snapshot.procs ?? 0)",
                            symbol: "clock"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("磁盘空间")
                            .font(.title3.weight(.semibold))
                        ForEach(snapshot.disks ?? []) { disk in
                            DiskUsageRow(disk: disk)
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))

                    if let battery = snapshot.batteries?.first {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("电池", systemImage: "battery.100")
                                .font(.title3.weight(.semibold))
                            HStack {
                                Text("电量")
                                Spacer()
                                Text(MoleDisplay.percent(battery.percent))
                                    .monospacedDigit()
                            }
                            HStack {
                                Text("健康度")
                                Spacer()
                                Text(battery.health ?? "—")
                            }
                            HStack {
                                Text("循环次数")
                                Spacer()
                                Text(battery.cycleCount.map(String.init) ?? "—")
                            }
                        }
                        .padding(16)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                    }

                    Text("最后更新：\(snapshot.collectedAt ?? "未知")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView(store.isRefreshing ? "正在读取系统状态…" : "请先读取系统状态")
                        .frame(maxWidth: .infinity, minHeight: 180)
                }
            }
            .padding(24)
        }
    }
}
