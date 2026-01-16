import Foundation

public enum TimerPhase: Equatable, Codable {
    case countdown
    case work
    case rest
    case finished

    public var displayName: String {
        switch self {
        case .countdown: return "GET READY"
        case .work: return "WORK"
        case .rest: return "REST"
        case .finished: return "DONE"
        }
    }

    public var colorName: String {
        switch self {
        case .countdown: return "rust"
        case .work: return "woodlandGreen"
        case .rest: return "slate"
        case .finished: return "granite"
        }
    }
}
