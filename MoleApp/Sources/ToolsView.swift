import SwiftUI

struct ToolsView: View {
    let store: DashboardStore
    let requestOperation: (MoleOperation) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageHeader(title: "清理工具", subtitle: "先预览，再在终端检查项目并确认实际操作。")

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(.green)
                            .frame(width: 42, height: 42)
                            .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("清理预览")
                                .font(.headline)
                            Text("只列出可处理项目，不会删除文件。系统级项目仅在已授权时纳入预览。")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            store.previewClean()
                        } label: {
                            if store.isPreviewing {
                                ProgressView().controlSize(.small)
                            } else {
                                Text("生成预览")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(store.isPreviewing)
                    }

                    if let error = store.previewError {
                        InlineError(message: error)
                    }
                    if let output = store.previewOutput {
                        ScrollView([.horizontal, .vertical]) {
                            Text(output.isEmpty ? "没有发现可预览的项目。" : output)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                        }
                        .frame(minHeight: 100, maxHeight: 280)
                        .background(.background, in: RoundedRectangle(cornerRadius: 9))
                    }
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 12) {
                    Text("在终端继续")
                        .font(.title3.weight(.semibold))
                    Text("终端保留 Mole 原有的逐项说明、授权与确认流程。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    ForEach(MoleOperation.allCases) { operation in
                        Button {
                            requestOperation(operation)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: operation.symbol)
                                    .font(.title3)
                                    .foregroundStyle(.green)
                                    .frame(width: 34)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(operation.title)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text(operation.detail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(.background, in: RoundedRectangle(cornerRadius: 10))
                    }
                    if let message = store.terminalMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(24)
        }
    }
}
