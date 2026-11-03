import Foundation
import Observation

@MainActor
@Observable
final class DashboardStore {
    private let client = MoleCommandClient()

    private(set) var snapshot: MetricsSnapshot?
    private(set) var isRefreshing = false
    private(set) var refreshError: String?

    private(set) var analysis: DiskAnalysisResponse?
    private(set) var isAnalyzing = false
    private(set) var analysisError: String?

    private(set) var previewOutput: String?
    private(set) var isPreviewing = false
    private(set) var previewError: String?
    private(set) var terminalMessage: String?

    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        refreshError = nil
        let client = self.client
        Task {
            defer { isRefreshing = false }
            do {
                snapshot = try await Task.detached(priority: .utility) {
                    try client.loadStatus()
                }.value
            } catch {
                refreshError = error.localizedDescription
            }
        }
    }

    func analyze(path: String) {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        analysis = nil
        analysisError = nil
        let client = self.client
        Task {
            defer { isAnalyzing = false }
            do {
                analysis = try await Task.detached(priority: .userInitiated) {
                    try client.analyze(path: path)
                }.value
            } catch {
                analysisError = error.localizedDescription
            }
        }
    }

    func previewClean() {
        guard !isPreviewing else { return }
        isPreviewing = true
        previewOutput = nil
        previewError = nil
        let client = self.client
        Task {
            defer { isPreviewing = false }
            do {
                previewOutput = try await Task.detached(priority: .userInitiated) {
                    try client.previewClean()
                }.value
            } catch {
                previewError = error.localizedDescription
            }
        }
    }

    func openInTerminal(_ operation: MoleOperation) {
        terminalMessage = nil
        do {
            try client.openInTerminal(operation)
            terminalMessage = "已在终端打开：\(operation.title)"
        } catch {
            terminalMessage = error.localizedDescription
        }
    }
}
