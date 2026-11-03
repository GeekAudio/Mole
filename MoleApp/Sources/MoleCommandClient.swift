import Darwin
import Foundation

struct MoleCommandClient: Sendable {
    func loadStatus() throws -> MetricsSnapshot {
        let output = try run(["status", "--json"])
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(MetricsSnapshot.self, from: Data(output.utf8))
        } catch {
            throw MoleCommandError.invalidOutput(error.localizedDescription)
        }
    }

    func analyze(path: String) throws -> DiskAnalysisResponse {
        let output = try run(["analyze", "--json", path])
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(DiskAnalysisResponse.self, from: Data(output.utf8))
        } catch {
            throw MoleCommandError.invalidOutput(error.localizedDescription)
        }
    }

    func previewClean() throws -> String {
        try run(["clean", "--dry-run"])
    }

    func openInTerminal(_ operation: MoleOperation) throws {
        let executable = try moleExecutable()
        let command = ([shellQuote(executable.path)] + operation.arguments.map(shellQuote))
            .joined(separator: " ")
        let script = """
        #!/bin/zsh
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"
        \(command)
        result=$?
        printf '\\nMole 已退出（状态码 %s）。按任意键关闭此窗口。' "$result"
        read -k 1 key
        exit "$result"
        """

        let scriptURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("mole-\(UUID().uuidString).command")
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: scriptURL.path)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", "Terminal", scriptURL.path]
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw MoleCommandError.terminalUnavailable
        }
    }

    private func run(_ arguments: [String]) throws -> String {
        let executable = try moleExecutable()
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("mole-app-\(UUID().uuidString).output")
        let errorURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("mole-app-\(UUID().uuidString).error")
        guard FileManager.default.createFile(atPath: outputURL.path, contents: nil, attributes: [.posixPermissions: 0o600]),
              FileManager.default.createFile(atPath: errorURL.path, contents: nil, attributes: [.posixPermissions: 0o600]) else {
            try? FileManager.default.removeItem(at: outputURL)
            try? FileManager.default.removeItem(at: errorURL)
            throw MoleCommandError.outputUnavailable
        }
        defer { try? FileManager.default.removeItem(at: outputURL) }
        defer { try? FileManager.default.removeItem(at: errorURL) }

        let outputHandle = try FileHandle(forWritingTo: outputURL)
        defer { try? outputHandle.close() }
        let errorHandle = try FileHandle(forWritingTo: errorURL)
        defer { try? errorHandle.close() }

        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        process.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        process.environment = commandEnvironment
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = outputHandle
        process.standardError = errorHandle

        do {
            try process.run()
        } catch {
            throw MoleCommandError.launchFailed(error.localizedDescription)
        }
        process.waitUntilExit()
        try outputHandle.synchronize()
        try outputHandle.close()
        try errorHandle.synchronize()
        try errorHandle.close()

        let output = String(decoding: try Data(contentsOf: outputURL), as: UTF8.self)
        guard process.terminationStatus == 0 else {
            let error = String(decoding: try Data(contentsOf: errorURL), as: UTF8.self)
            let message = [output, error].filter { !$0.isEmpty }.joined(separator: "\n")
            throw MoleCommandError.commandFailed(message.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var commandEnvironment: [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        environment["HOME"] = home
        environment["PATH"] = "\(home)/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
        environment["LANG"] = "zh_CN.UTF-8"
        environment["LC_ALL"] = "zh_CN.UTF-8"
        return environment
    }

    private func moleExecutable() throws -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let candidates = [
            home.appendingPathComponent(".local/bin/mole"),
            URL(fileURLWithPath: "/opt/homebrew/bin/mole"),
            URL(fileURLWithPath: "/usr/local/bin/mole"),
        ]
        guard let executable = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0.path) }) else {
            throw MoleCommandError.executableMissing
        }
        return executable
    }

    private func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}

private enum MoleCommandError: LocalizedError {
    case executableMissing
    case outputUnavailable
    case terminalUnavailable
    case launchFailed(String)
    case invalidOutput(String)
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .executableMissing:
            "找不到 Mole 命令。请先安装中文 CLI，并确认它位于 ~/.local/bin/mole。"
        case .outputUnavailable:
            "无法为 Mole 命令创建安全的临时输出文件。"
        case .terminalUnavailable:
            "无法打开终端。请确认系统中的 Terminal 应用可用。"
        case let .launchFailed(message):
            "无法启动 Mole：\(message)"
        case let .invalidOutput(message):
            "Mole 返回的数据无法读取：\(message)"
        case let .commandFailed(output):
            output.isEmpty ? "Mole 命令执行失败。" : output
        }
    }
}
