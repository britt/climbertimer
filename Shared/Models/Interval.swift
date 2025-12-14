import Foundation
import SwiftData

@Model
public class Interval {
    public var id: UUID
    public var name: String
    public var workDuration: TimeInterval
    public var restDuration: TimeInterval
    public var repetitions: Int
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        workDuration: TimeInterval,
        restDuration: TimeInterval,
        repetitions: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.repetitions = repetitions
        self.createdAt = createdAt
    }

    public var totalDuration: TimeInterval {
        Double(repetitions) * (workDuration + restDuration)
    }

    public var summary: String {
        "\(Int(workDuration))s / \(Int(restDuration))s × \(repetitions)"
    }
}
