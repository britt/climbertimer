import Foundation

public enum TimerPhase: Equatable {
    case work
    case rest
    case finished

    public var displayName: String {
        switch self {
        case .work: return "WORK"
        case .rest: return "REST"
        case .finished: return "DONE"
        }
    }

    public var colorName: String {
        switch self {
        case .work: return "green"
        case .rest: return "blue"
        case .finished: return "gray"
        }
    }
}
