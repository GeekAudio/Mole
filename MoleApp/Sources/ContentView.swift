import SwiftUI

struct ContentView: View {
    @State private var selection: AppSection? = .overview
    @State private var store = DashboardStore()
    @State private var pendingOperation: MoleOperation?
    @State private var showingTerminalConfirmation = false

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.symbol)
                }
            }
            .listStyle(.sidebar)
            .safeAreaInset(edge: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Label("Mole 中文版", systemImage: "leaf.fill")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("macOS 清理与维护")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationSplitViewColumnWidth(min: 175, ideal: 205, max: 250)
        } detail: {
            detailView
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            store.refresh()
                        } label: {
                            if store.isRefreshing {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Label("刷新状态", systemImage: "arrow.clockwise")
                            }
                        }
                        .disabled(store.isRefreshing)
                        .help("重新读取 Mole 系统状态")
                    }
                }
        }
        .tint(.green)
        .confirmationDialog(
            "在终端继续操作？",
            isPresented: $showingTerminalConfirmation,
            titleVisibility: .visible
        ) {
            Button("打开终端并查看确认项") {
                if let pendingOperation {
                    store.openInTerminal(pendingOperation)
                }
                pendingOperation = nil
            }
            Button("取消", role: .cancel) {
                pendingOperation = nil
            }
        } message: {
            if let pendingOperation {
                Text("\(pendingOperation.title) 将在 Terminal 中运行。请先查看 Mole 显示的项目，再确认实际变更。")
            }
        }
        .task {
            store.refresh()
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .overview {
        case .overview:
            OverviewView(
                store: store,
                openAnalysis: { selection = .analysis },
                openTools: { selection = .tools; store.previewClean() }
            )
        case .analysis:
            DiskAnalysisView(store: store)
        case .status:
            SystemStatusView(store: store)
        case .tools:
            ToolsView(store: store) { operation in
                pendingOperation = operation
                showingTerminalConfirmation = true
            }
        }
    }
}

struct PageHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String
    var progress: Double? = nil
    var tint: Color = .green

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 27, weight: .semibold, design: .rounded))
                .contentTransition(.numericText())
            if let progress {
                ProgressView(value: min(max(progress, 0), 100), total: 100)
                    .tint(tint)
            }
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct DiskUsageRow: View {
    let disk: DiskStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Label(disk.mount, systemImage: disk.external == true ? "externaldrive" : "internaldrive")
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text("\(MoleDisplay.bytes(disk.used)) / \(MoleDisplay.bytes(disk.total))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(max(disk.usedPercent ?? 0, 0), 100), total: 100)
                .tint((disk.usedPercent ?? 0) >= 90 ? .orange : .green)
        }
        .padding(.vertical, 5)
    }
}

struct InlineError: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.callout)
            .foregroundStyle(.orange)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
            .textSelection(.enabled)
    }
}
