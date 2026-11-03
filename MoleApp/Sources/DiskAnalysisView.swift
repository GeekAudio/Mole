import SwiftUI
import UniformTypeIdentifiers

struct DiskAnalysisView: View {
    let store: DashboardStore
    @State private var selectedFolder = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
    @State private var showingFolderPicker = false
    @State private var scopedFolder: URL?

    private var entries: [DiskEntry] {
        Array((store.analysis?.entries ?? []).prefix(120))
    }

    private var largestEntry: Int64 {
        max(entries.map(\.size).max() ?? 1, 1)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PageHeader(title: "磁盘分析", subtitle: "扫描选定目录，按占用空间查看文件与子目录。")

                HStack(spacing: 12) {
                    Label(selectedFolder.path, systemImage: "folder")
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("选择文件夹…") { showingFolderPicker = true }
                        .buttonStyle(.bordered)
                    Button {
                        store.analyze(path: selectedFolder.path)
                    } label: {
                        if store.isAnalyzing {
                            ProgressView().controlSize(.small)
                        } else {
                            Label("开始分析", systemImage: "magnifyingglass")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.isAnalyzing)
                }
                .padding(14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                if let error = store.analysisError {
                    InlineError(message: error)
                }

                if let analysis = store.analysis {
                    HStack(spacing: 14) {
                        MetricCard(
                            title: "目录占用",
                            value: MoleDisplay.bytes(analysis.totalSize),
                            detail: analysis.path ?? selectedFolder.path,
                            symbol: "externaldrive"
                        )
                        MetricCard(
                            title: "文件数量",
                            value: NumberFormatter.localizedString(from: NSNumber(value: analysis.totalFiles ?? 0), number: .decimal),
                            detail: "当前目录及其子目录",
                            symbol: "doc.on.doc"
                        )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("最大项目")
                            .font(.title3.weight(.semibold))
                            .padding(.bottom, 6)
                        if entries.isEmpty {
                            ContentUnavailableView("没有可显示的项目", systemImage: "folder.badge.questionmark")
                                .frame(minHeight: 150)
                        } else {
                            ForEach(entries) { entry in
                                HStack(spacing: 12) {
                                    Image(systemName: entry.isDir ? "folder.fill" : "doc")
                                        .foregroundStyle(entry.isDir ? .blue : .secondary)
                                        .frame(width: 20)
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(entry.name)
                                                .lineLimit(1)
                                            if entry.insight == true {
                                                Text("重点")
                                                    .font(.caption2.weight(.semibold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(.orange.opacity(0.15), in: Capsule())
                                            }
                                            Spacer()
                                            Text(MoleDisplay.bytes(entry.size))
                                                .font(.caption.monospacedDigit())
                                                .foregroundStyle(.secondary)
                                        }
                                        ProgressView(value: Double(entry.size), total: Double(largestEntry))
                                            .tint(entry.insight == true ? .orange : .green)
                                    }
                                }
                                .padding(.vertical, 5)
                                .help(entry.path)
                            }
                            if (analysis.entries?.count ?? 0) > entries.count {
                                Text("仅显示前 \(entries.count) 项；使用 Mole 的交互式分析器可继续浏览。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                } else if store.isAnalyzing {
                    ProgressView("正在分析目录…")
                        .frame(maxWidth: .infinity, minHeight: 180)
                } else {
                    ContentUnavailableView {
                        Label("选择一个文件夹开始", systemImage: "folder.badge.magnifyingglass")
                    } description: {
                        Text("分析只读取目录内容，不会删除文件。")
                    }
                    .frame(maxWidth: .infinity, minHeight: 190)
                }
            }
            .padding(24)
        }
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            guard case let .success(urls) = result, let url = urls.first else { return }
            scopedFolder?.stopAccessingSecurityScopedResource()
            scopedFolder = url.startAccessingSecurityScopedResource() ? url : nil
            selectedFolder = url
        }
        .onChange(of: store.isAnalyzing) { _, isAnalyzing in
            if !isAnalyzing {
                scopedFolder?.stopAccessingSecurityScopedResource()
                scopedFolder = nil
            }
        }
        .onDisappear {
            scopedFolder?.stopAccessingSecurityScopedResource()
            scopedFolder = nil
        }
    }
}
