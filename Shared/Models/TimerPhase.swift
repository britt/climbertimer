import Foundation

public enum TimerPhase: Equatable {
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
        case .countdown: return "orange"
        case .work: return "green"
        case .rest: return "blue"
        case .finished: return "gray"
        }
    }
}
