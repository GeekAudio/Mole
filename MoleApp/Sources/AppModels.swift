import Foundation

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case overview
    case analysis
    case status
    case tools

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "概览"
        case .analysis: "磁盘分析"
        case .status: "系统状态"
        case .tools: "清理工具"
        }
    }

    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .analysis: "externaldrive"
        case .status: "waveform.path.ecg"
        case .tools: "sparkles"
        }
    }
}

struct MetricsSnapshot: Decodable, Sendable {
    let collectedAt: String?
    let host: String?
    let platform: String?
    let uptime: String?
    let procs: UInt64?
    let healthScore: Int?
    let healthScoreMsg: String?
    let cpu: CPUStatus?
    let memory: MemoryStatus?
    let disks: [DiskStatus]?
    let network: [NetworkStatus]?
    let batteries: [BatteryStatus]?
    let thermal: ThermalStatus?
}

struct CPUStatus: Decodable, Sendable {
    let usage: Double?
    let coreCount: Int?
    let logicalCpu: Int?
}

struct MemoryStatus: Decodable, Sendable {
    let used: UInt64?
    let total: UInt64?
    let available: UInt64?
    let usedPercent: Double?
    let pressure: String?
}

struct DiskStatus: Decodable, Sendable, Identifiable {
    let mount: String
    let device: String?
    let used: UInt64?
    let total: UInt64?
    let usedPercent: Double?
    let external: Bool?
    let smartStatus: String?

    var id: String { mount }
}

struct NetworkStatus: Decodable, Sendable, Identifiable {
    let name: String
    let rxRateMbs: Double?
    let txRateMbs: Double?
    let ip: String?

    var id: String { name }
}

struct BatteryStatus: Decodable, Sendable, Identifiable {
    let percent: Double?
    let status: String?
    let health: String?
    let cycleCount: Int?
    let capacity: Int?

    var id: Int { cycleCount ?? Int(percent ?? 0) }
}

struct ThermalStatus: Decodable, Sendable {
    let cpuTemp: Double?
    let gpuTemp: Double?
    let fanSpeed: Int?
}

struct DiskAnalysisResponse: Decodable, Sendable {
    let scanStatus: String?
    let path: String?
    let overview: Bool?
    let entries: [DiskEntry]?
    let totalSize: Int64?
    let totalFiles: Int64?
}

struct DiskEntry: Decodable, Sendable, Identifiable {
    let scanStatus: String?
    let name: String
    let path: String
    let size: Int64
    let isDir: Bool
    let insight: Bool?
    let cleanable: Bool?

    var id: String { path }
}

enum MoleOperation: String, CaseIterable, Identifiable, Sendable {
    case clean
    case optimize
    case purge
    case installer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clean: "清理缓存与残留"
        case .optimize: "刷新系统缓存与服务"
        case .purge: "清理旧项目产物"
        case .installer: "清理安装包"
        }
    }

    var detail: String {
        switch self {
        case .clean: "查看清理项目，并在终端确认实际操作。"
        case .optimize: "在终端查看 Mole 将执行的维护步骤。"
        case .purge: "在终端检查旧构建产物后再确认删除。"
        case .installer: "在终端检查安装镜像与安装包后再确认。"
        }
    }

    var symbol: String {
        switch self {
        case .clean: "broom"
        case .optimize: "gearshape.2"
        case .purge: "shippingbox"
        case .installer: "externaldrive.badge.minus"
        }
    }

    var arguments: [String] {
        switch self {
        case .clean: ["clean"]
        case .optimize: ["optimize"]
        case .purge: ["purge"]
        case .installer: ["installer"]
        }
    }
}

enum MoleDisplay {
    static func bytes(_ value: Int64?) -> String {
        guard let value, value >= 0 else { return "—" }
        return ByteCountFormatter.string(fromByteCount: value, countStyle: .file)
    }

    static func bytes(_ value: UInt64?) -> String {
        guard let value, value <= UInt64(Int64.max) else { return "—" }
        return bytes(Int64(value))
    }

    static func percent(_ value: Double?) -> String {
        guard let value, value.isFinite else { return "—" }
        return "\(Int(value.rounded()))%"
    }
}
