# ClimberTimer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a SwiftUI interval timer app for hangboard training with iPhone + Apple Watch support and iCloud sync.

**Architecture:** MVVM with shared business logic. Models and Services in Shared module, platform-specific Views. SwiftData with CloudKit for preset sync, UserDefaults with App Group for last-used settings.

**Tech Stack:** SwiftUI, SwiftData, CloudKit, AVFoundation (audio), Core Haptics, WatchKit

---

## Task 0: Xcode Project Setup

**Files:**
- Create: `ClimberTimer.xcodeproj`
- Create: `Shared/` directory
- Create: `ClimberTimer iOS/` directory
- Create: `ClimberTimer Watch/` directory
- Create: `ClimberTimerTests/` directory

**Step 1: Create Xcode project**

Open Xcode and create a new project:
1. File → New → Project
2. Select "App" under iOS
3. Product Name: `ClimberTimer`
4. Team: Your development team
5. Organization Identifier: `com.yourname`
6. Interface: SwiftUI
7. Language: Swift
8. Storage: SwiftData
9. Check "Include Tests"

**Step 2: Add watchOS target**

1. File → New → Target
2. Select "App" under watchOS
3. Product Name: `ClimberTimer Watch`
4. Interface: SwiftUI
5. Language: Swift
6. Watch App for Existing iOS App: ClimberTimer

**Step 3: Create Shared framework**

1. File → New → Target
2. Select "Framework" under iOS
3. Product Name: `Shared`
4. Embed in both iOS and watchOS targets

**Step 4: Configure App Group**

1. Select ClimberTimer iOS target → Signing & Capabilities → + Capability → App Groups
2. Add: `group.com.yourname.climbertimer`
3. Repeat for watchOS target

**Step 5: Create directory structure**

```
ClimberTimer/
├── Shared/
│   ├── Models/
│   ├── Services/
│   └── Utilities/
├── ClimberTimer iOS/
│   ├── App/
│   └── Views/
├── ClimberTimer Watch/
│   ├── App/
│   └── Views/
└── ClimberTimerTests/
    ├── Models/
    └── Services/
```

**Step 6: Verify both targets build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 7: Commit**

```bash
git add .
git commit -m "chore: initial Xcode project setup with iOS + watchOS targets"
```

---

## Task 1: Interval Model (TDD)

**Files:**
- Create: `Shared/Models/Interval.swift`
- Create: `ClimberTimerTests/Models/IntervalTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/Models/IntervalTests.swift`:

```swift
import XCTest
@testable import Shared

final class IntervalTests: XCTestCase {

    func test_interval_initialization_with_valid_values() {
        let interval = Interval(
            name: "Repeaters",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        XCTAssertEqual(interval.name, "Repeaters")
        XCTAssertEqual(interval.workDuration, 7)
        XCTAssertEqual(interval.restDuration, 3)
        XCTAssertEqual(interval.repetitions, 6)
        XCTAssertNotNil(interval.id)
        XCTAssertNotNil(interval.createdAt)
    }

    func test_interval_total_duration() {
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        // 6 reps × (7s work + 3s rest) = 60s
        XCTAssertEqual(interval.totalDuration, 60)
    }

    func test_interval_summary_string() {
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        XCTAssertEqual(interval.summary, "7s / 3s × 6")
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTests`

Expected: FAIL - "No such module 'Shared'" or "Cannot find 'Interval' in scope"

**Step 3: Write minimal implementation**

Create `Shared/Models/Interval.swift`:

```swift
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
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTests`

Expected: PASS - All 3 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Models/Interval.swift ClimberTimerTests/Models/IntervalTests.swift
git commit -m "feat(models): add Interval model with TDD

- RED: wrote tests for initialization, totalDuration, summary
- GREEN: implemented Interval @Model class
- Status: 3 tests passing, both platforms build"
```

---

## Task 2: FeedbackSettings Model (TDD)

**Files:**
- Create: `Shared/Models/FeedbackSettings.swift`
- Create: `ClimberTimerTests/Models/FeedbackSettingsTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/Models/FeedbackSettingsTests.swift`:

```swift
import XCTest
@testable import Shared

final class FeedbackSettingsTests: XCTestCase {

    func test_default_settings_all_enabled() {
        let settings = FeedbackSettings()

        XCTAssertTrue(settings.audioEnabled)
        XCTAssertTrue(settings.visualEnabled)
        XCTAssertTrue(settings.hapticsEnabled)
    }

    func test_settings_can_be_modified() {
        var settings = FeedbackSettings()

        settings.audioEnabled = false
        settings.hapticsEnabled = false

        XCTAssertFalse(settings.audioEnabled)
        XCTAssertTrue(settings.visualEnabled)
        XCTAssertFalse(settings.hapticsEnabled)
    }

    func test_settings_codable() throws {
        let settings = FeedbackSettings(
            audioEnabled: false,
            visualEnabled: true,
            hapticsEnabled: false
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(FeedbackSettings.self, from: data)

        XCTAssertEqual(settings.audioEnabled, decoded.audioEnabled)
        XCTAssertEqual(settings.visualEnabled, decoded.visualEnabled)
        XCTAssertEqual(settings.hapticsEnabled, decoded.hapticsEnabled)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/FeedbackSettingsTests`

Expected: FAIL - "Cannot find 'FeedbackSettings' in scope"

**Step 3: Write minimal implementation**

Create `Shared/Models/FeedbackSettings.swift`:

```swift
import Foundation

public struct FeedbackSettings: Codable, Equatable {
    public var audioEnabled: Bool
    public var visualEnabled: Bool
    public var hapticsEnabled: Bool

    public init(
        audioEnabled: Bool = true,
        visualEnabled: Bool = true,
        hapticsEnabled: Bool = true
    ) {
        self.audioEnabled = audioEnabled
        self.visualEnabled = visualEnabled
        self.hapticsEnabled = hapticsEnabled
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/FeedbackSettingsTests`

Expected: PASS - All 3 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Models/FeedbackSettings.swift ClimberTimerTests/Models/FeedbackSettingsTests.swift
git commit -m "feat(models): add FeedbackSettings with TDD

- RED: wrote tests for defaults, modification, Codable
- GREEN: implemented FeedbackSettings struct
- Status: 6 tests passing, both platforms build"
```

---

## Task 3: Timer Phase Enum (TDD)

**Files:**
- Create: `Shared/Models/TimerPhase.swift`
- Create: `ClimberTimerTests/Models/TimerPhaseTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/Models/TimerPhaseTests.swift`:

```swift
import XCTest
@testable import Shared

final class TimerPhaseTests: XCTestCase {

    func test_phase_display_names() {
        XCTAssertEqual(TimerPhase.work.displayName, "WORK")
        XCTAssertEqual(TimerPhase.rest.displayName, "REST")
        XCTAssertEqual(TimerPhase.finished.displayName, "DONE")
    }

    func test_phase_colors() {
        XCTAssertEqual(TimerPhase.work.colorName, "green")
        XCTAssertEqual(TimerPhase.rest.colorName, "blue")
        XCTAssertEqual(TimerPhase.finished.colorName, "gray")
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/TimerPhaseTests`

Expected: FAIL - "Cannot find 'TimerPhase' in scope"

**Step 3: Write minimal implementation**

Create `Shared/Models/TimerPhase.swift`:

```swift
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
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/TimerPhaseTests`

Expected: PASS - All 2 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Models/TimerPhase.swift ClimberTimerTests/Models/TimerPhaseTests.swift
git commit -m "feat(models): add TimerPhase enum with TDD

- RED: wrote tests for displayName and colorName
- GREEN: implemented TimerPhase enum
- Status: 8 tests passing, both platforms build"
```

---

## Task 4: IntervalTimer Service - Basic State (TDD)

**Files:**
- Create: `Shared/Services/IntervalTimer.swift`
- Create: `ClimberTimerTests/Services/IntervalTimerTests.swift`

**Step 1: Write the failing test for initialization**

Create `ClimberTimerTests/Services/IntervalTimerTests.swift`:

```swift
import XCTest
@testable import Shared

final class IntervalTimerTests: XCTestCase {

    func test_initial_state() {
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )
        let timer = IntervalTimer(interval: interval)

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.currentRep, 1)
        XCTAssertEqual(timer.timeRemaining, 7)
        XCTAssertFalse(timer.isRunning)
    }

    func test_total_reps() {
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )
        let timer = IntervalTimer(interval: interval)

        XCTAssertEqual(timer.totalReps, 6)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: FAIL - "Cannot find 'IntervalTimer' in scope"

**Step 3: Write minimal implementation**

Create `Shared/Services/IntervalTimer.swift`:

```swift
import Foundation
import Combine

@Observable
public class IntervalTimer {
    public private(set) var currentPhase: TimerPhase = .work
    public private(set) var currentRep: Int = 1
    public private(set) var timeRemaining: TimeInterval = 0
    public private(set) var isRunning: Bool = false

    public let totalReps: Int

    private let workDuration: TimeInterval
    private let restDuration: TimeInterval

    public init(interval: Interval) {
        self.workDuration = interval.workDuration
        self.restDuration = interval.restDuration
        self.totalReps = interval.repetitions
        self.timeRemaining = interval.workDuration
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: PASS - All 2 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/IntervalTimer.swift ClimberTimerTests/Services/IntervalTimerTests.swift
git commit -m "feat(services): add IntervalTimer with initial state - TDD

- RED: wrote tests for initial state and totalReps
- GREEN: implemented IntervalTimer @Observable class
- Status: 10 tests passing, both platforms build"
```

---

## Task 5: IntervalTimer Service - Start/Pause/Resume (TDD)

**Files:**
- Modify: `Shared/Services/IntervalTimer.swift`
- Modify: `ClimberTimerTests/Services/IntervalTimerTests.swift`

**Step 1: Write the failing tests**

Add to `ClimberTimerTests/Services/IntervalTimerTests.swift`:

```swift
    func test_start_sets_running_true() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()

        XCTAssertTrue(timer.isRunning)
    }

    func test_pause_sets_running_false() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()
        timer.pause()

        XCTAssertFalse(timer.isRunning)
    }

    func test_resume_sets_running_true() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()
        timer.pause()
        timer.resume()

        XCTAssertTrue(timer.isRunning)
    }
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: FAIL - "Value of type 'IntervalTimer' has no member 'start'"

**Step 3: Write minimal implementation**

Add to `Shared/Services/IntervalTimer.swift` inside the class:

```swift
    private var timerCancellable: AnyCancellable?

    public func start() {
        isRunning = true
        startTimer()
    }

    public func pause() {
        isRunning = false
        timerCancellable?.cancel()
    }

    public func resume() {
        isRunning = true
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard isRunning else { return }
        // Will implement countdown logic in next task
    }
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: PASS - All 5 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/IntervalTimer.swift ClimberTimerTests/Services/IntervalTimerTests.swift
git commit -m "feat(services): add start/pause/resume to IntervalTimer - TDD

- RED: wrote tests for start, pause, resume state changes
- GREEN: implemented control methods with Timer.publish
- Status: 13 tests passing, both platforms build"
```

---

## Task 6: IntervalTimer Service - Reset (TDD)

**Files:**
- Modify: `Shared/Services/IntervalTimer.swift`
- Modify: `ClimberTimerTests/Services/IntervalTimerTests.swift`

**Step 1: Write the failing test**

Add to `ClimberTimerTests/Services/IntervalTimerTests.swift`:

```swift
    func test_reset_returns_to_initial_state() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()
        // Simulate some state change
        timer.pause()
        timer.reset()

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.currentRep, 1)
        XCTAssertEqual(timer.timeRemaining, 7)
        XCTAssertFalse(timer.isRunning)
    }
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests/test_reset_returns_to_initial_state`

Expected: FAIL - "Value of type 'IntervalTimer' has no member 'reset'"

**Step 3: Write minimal implementation**

Add to `Shared/Services/IntervalTimer.swift` inside the class:

```swift
    public func reset() {
        timerCancellable?.cancel()
        isRunning = false
        currentPhase = .work
        currentRep = 1
        timeRemaining = workDuration
    }
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: PASS - All 6 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/IntervalTimer.swift ClimberTimerTests/Services/IntervalTimerTests.swift
git commit -m "feat(services): add reset to IntervalTimer - TDD

- RED: wrote test for reset returning to initial state
- GREEN: implemented reset method
- Status: 14 tests passing, both platforms build"
```

---

## Task 7: IntervalTimer Service - Countdown Logic (TDD)

**Files:**
- Modify: `Shared/Services/IntervalTimer.swift`
- Modify: `ClimberTimerTests/Services/IntervalTimerTests.swift`

**Step 1: Write the failing tests**

Add to `ClimberTimerTests/Services/IntervalTimerTests.swift`:

```swift
    func test_tick_decrements_time_remaining() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.simulateTick(seconds: 1)

        XCTAssertEqual(timer.timeRemaining, 6, accuracy: 0.1)
    }

    func test_work_phase_ends_transitions_to_rest() {
        let interval = Interval(name: "Test", workDuration: 2, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.simulateTick(seconds: 2)

        XCTAssertEqual(timer.currentPhase, .rest)
        XCTAssertEqual(timer.timeRemaining, 3, accuracy: 0.1)
    }

    func test_rest_phase_ends_increments_rep_and_returns_to_work() {
        let interval = Interval(name: "Test", workDuration: 2, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        // Complete work phase
        timer.simulateTick(seconds: 2)
        // Complete rest phase
        timer.simulateTick(seconds: 3)

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.currentRep, 2)
        XCTAssertEqual(timer.timeRemaining, 2, accuracy: 0.1)
    }

    func test_final_rep_ends_transitions_to_finished() {
        let interval = Interval(name: "Test", workDuration: 1, restDuration: 1, repetitions: 2)
        let timer = IntervalTimer(interval: interval)

        // Rep 1: work + rest
        timer.simulateTick(seconds: 2)
        // Rep 2: work + rest
        timer.simulateTick(seconds: 2)

        XCTAssertEqual(timer.currentPhase, .finished)
        XCTAssertFalse(timer.isRunning)
    }
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: FAIL - "Value of type 'IntervalTimer' has no member 'simulateTick'"

**Step 3: Write minimal implementation**

Update `Shared/Services/IntervalTimer.swift`:

```swift
import Foundation
import Combine

@Observable
public class IntervalTimer {
    public private(set) var currentPhase: TimerPhase = .work
    public private(set) var currentRep: Int = 1
    public private(set) var timeRemaining: TimeInterval = 0
    public private(set) var isRunning: Bool = false

    public let totalReps: Int

    private let workDuration: TimeInterval
    private let restDuration: TimeInterval
    private var timerCancellable: AnyCancellable?

    public init(interval: Interval) {
        self.workDuration = interval.workDuration
        self.restDuration = interval.restDuration
        self.totalReps = interval.repetitions
        self.timeRemaining = interval.workDuration
    }

    public func start() {
        isRunning = true
        startTimer()
    }

    public func pause() {
        isRunning = false
        timerCancellable?.cancel()
    }

    public func resume() {
        isRunning = true
        startTimer()
    }

    public func reset() {
        timerCancellable?.cancel()
        isRunning = false
        currentPhase = .work
        currentRep = 1
        timeRemaining = workDuration
    }

    // For testing - simulates elapsed time
    public func simulateTick(seconds: TimeInterval) {
        var remaining = seconds
        while remaining > 0 {
            let tickAmount = min(0.1, remaining)
            timeRemaining -= tickAmount
            remaining -= tickAmount

            if timeRemaining <= 0 {
                handlePhaseTransition()
            }
        }
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard isRunning else { return }

        timeRemaining -= 0.1

        if timeRemaining <= 0 {
            handlePhaseTransition()
        }
    }

    private func handlePhaseTransition() {
        switch currentPhase {
        case .work:
            currentPhase = .rest
            timeRemaining = restDuration

        case .rest:
            if currentRep >= totalReps {
                currentPhase = .finished
                isRunning = false
                timerCancellable?.cancel()
            } else {
                currentRep += 1
                currentPhase = .work
                timeRemaining = workDuration
            }

        case .finished:
            break
        }
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: PASS - All 10 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/IntervalTimer.swift ClimberTimerTests/Services/IntervalTimerTests.swift
git commit -m "feat(services): add countdown logic to IntervalTimer - TDD

- RED: wrote tests for tick, phase transitions, rep increments
- GREEN: implemented handlePhaseTransition and simulateTick
- Status: 18 tests passing, both platforms build"
```

---

## Task 8: IntervalTimer Service - Countdown Warning (TDD)

**Files:**
- Modify: `Shared/Services/IntervalTimer.swift`
- Modify: `ClimberTimerTests/Services/IntervalTimerTests.swift`

**Step 1: Write the failing test**

Add to `ClimberTimerTests/Services/IntervalTimerTests.swift`:

```swift
    func test_isInCountdownWarning_true_when_3_seconds_or_less() {
        let interval = Interval(name: "Test", workDuration: 5, restDuration: 3, repetitions: 1)
        let timer = IntervalTimer(interval: interval)

        XCTAssertFalse(timer.isInCountdownWarning) // 5 seconds

        timer.simulateTick(seconds: 2) // 3 seconds remaining
        XCTAssertTrue(timer.isInCountdownWarning)

        timer.simulateTick(seconds: 1) // 2 seconds remaining
        XCTAssertTrue(timer.isInCountdownWarning)
    }

    func test_countdownWarningSecond_returns_current_warning_second() {
        let interval = Interval(name: "Test", workDuration: 5, restDuration: 3, repetitions: 1)
        let timer = IntervalTimer(interval: interval)

        timer.simulateTick(seconds: 2) // 3 seconds remaining
        XCTAssertEqual(timer.countdownWarningSecond, 3)

        timer.simulateTick(seconds: 1) // 2 seconds remaining
        XCTAssertEqual(timer.countdownWarningSecond, 2)

        timer.simulateTick(seconds: 1) // 1 second remaining
        XCTAssertEqual(timer.countdownWarningSecond, 1)
    }
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: FAIL - "Value of type 'IntervalTimer' has no member 'isInCountdownWarning'"

**Step 3: Write minimal implementation**

Add to `Shared/Services/IntervalTimer.swift` inside the class:

```swift
    public var isInCountdownWarning: Bool {
        timeRemaining <= 3 && timeRemaining > 0 && currentPhase != .finished
    }

    public var countdownWarningSecond: Int? {
        guard isInCountdownWarning else { return nil }
        return Int(ceil(timeRemaining))
    }
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/IntervalTimerTests`

Expected: PASS - All 12 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/IntervalTimer.swift ClimberTimerTests/Services/IntervalTimerTests.swift
git commit -m "feat(services): add countdown warning to IntervalTimer - TDD

- RED: wrote tests for isInCountdownWarning and countdownWarningSecond
- GREEN: implemented computed properties for 3-second warning
- Status: 20 tests passing, both platforms build"
```

---

## Task 9: TimeFormatting Utility (TDD)

**Files:**
- Create: `Shared/Utilities/TimeFormatting.swift`
- Create: `ClimberTimerTests/Utilities/TimeFormattingTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/Utilities/TimeFormattingTests.swift`:

```swift
import XCTest
@testable import Shared

final class TimeFormattingTests: XCTestCase {

    func test_format_seconds_only() {
        XCTAssertEqual(TimeFormatting.format(7), "0:07")
        XCTAssertEqual(TimeFormatting.format(45), "0:45")
    }

    func test_format_minutes_and_seconds() {
        XCTAssertEqual(TimeFormatting.format(60), "1:00")
        XCTAssertEqual(TimeFormatting.format(90), "1:30")
        XCTAssertEqual(TimeFormatting.format(125), "2:05")
    }

    func test_format_with_decimal() {
        XCTAssertEqual(TimeFormatting.format(7.5), "0:07")
        XCTAssertEqual(TimeFormatting.format(7.9), "0:07")
    }

    func test_format_zero() {
        XCTAssertEqual(TimeFormatting.format(0), "0:00")
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/TimeFormattingTests`

Expected: FAIL - "Cannot find 'TimeFormatting' in scope"

**Step 3: Write minimal implementation**

Create `Shared/Utilities/TimeFormatting.swift`:

```swift
import Foundation

public enum TimeFormatting {
    public static func format(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/TimeFormattingTests`

Expected: PASS - All 4 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Utilities/TimeFormatting.swift ClimberTimerTests/Utilities/TimeFormattingTests.swift
git commit -m "feat(utilities): add TimeFormatting with TDD

- RED: wrote tests for various time formats
- GREEN: implemented format function
- Status: 24 tests passing, both platforms build"
```

---

## Task 10: DataStore Service - Presets (TDD)

**Files:**
- Create: `Shared/Services/DataStore.swift`
- Create: `ClimberTimerTests/Services/DataStoreTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/Services/DataStoreTests.swift`:

```swift
import XCTest
import SwiftData
@testable import Shared

final class DataStoreTests: XCTestCase {

    var dataStore: DataStore!
    var modelContainer: ModelContainer!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: Interval.self, configurations: config)
        dataStore = DataStore(modelContainer: modelContainer)
    }

    override func tearDown() {
        dataStore = nil
        modelContainer = nil
        super.tearDown()
    }

    func test_save_preset() throws {
        let interval = Interval(
            name: "Test Preset",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        try dataStore.savePreset(interval)

        let presets = dataStore.fetchPresets()
        XCTAssertEqual(presets.count, 1)
        XCTAssertEqual(presets.first?.name, "Test Preset")
    }

    func test_fetch_presets_ordered_by_creation_date() throws {
        let interval1 = Interval(name: "First", workDuration: 5, restDuration: 2, repetitions: 3)
        let interval2 = Interval(name: "Second", workDuration: 7, restDuration: 3, repetitions: 6)

        try dataStore.savePreset(interval1)
        try dataStore.savePreset(interval2)

        let presets = dataStore.fetchPresets()
        XCTAssertEqual(presets.count, 2)
        XCTAssertEqual(presets[0].name, "Second") // Most recent first
        XCTAssertEqual(presets[1].name, "First")
    }

    func test_delete_preset() throws {
        let interval = Interval(name: "To Delete", workDuration: 5, restDuration: 2, repetitions: 3)
        try dataStore.savePreset(interval)

        let presets = dataStore.fetchPresets()
        XCTAssertEqual(presets.count, 1)

        try dataStore.deletePreset(presets[0])

        let updatedPresets = dataStore.fetchPresets()
        XCTAssertEqual(updatedPresets.count, 0)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/DataStoreTests`

Expected: FAIL - "Cannot find 'DataStore' in scope"

**Step 3: Write minimal implementation**

Create `Shared/Services/DataStore.swift`:

```swift
import Foundation
import SwiftData

@Observable
public class DataStore {
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    public func savePreset(_ interval: Interval) throws {
        modelContext.insert(interval)
        try modelContext.save()
    }

    public func fetchPresets() -> [Interval] {
        let descriptor = FetchDescriptor<Interval>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func deletePreset(_ interval: Interval) throws {
        modelContext.delete(interval)
        try modelContext.save()
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/DataStoreTests`

Expected: PASS - All 3 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/DataStore.swift ClimberTimerTests/Services/DataStoreTests.swift
git commit -m "feat(services): add DataStore for presets with TDD

- RED: wrote tests for save, fetch, delete presets
- GREEN: implemented DataStore with SwiftData
- Status: 27 tests passing, both platforms build"
```

---

## Task 11: DataStore Service - Last Used (TDD)

**Files:**
- Modify: `Shared/Services/DataStore.swift`
- Modify: `ClimberTimerTests/Services/DataStoreTests.swift`

**Step 1: Write the failing tests**

Add to `ClimberTimerTests/Services/DataStoreTests.swift`:

```swift
    func test_save_and_load_last_used() {
        let interval = Interval(
            name: "Last Used",
            workDuration: 10,
            restDuration: 5,
            repetitions: 4
        )

        dataStore.saveLastUsed(interval)

        let loaded = dataStore.loadLastUsed()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.workDuration, 10)
        XCTAssertEqual(loaded?.restDuration, 5)
        XCTAssertEqual(loaded?.repetitions, 4)
    }

    func test_load_last_used_returns_nil_when_none_saved() {
        let loaded = dataStore.loadLastUsed()
        XCTAssertNil(loaded)
    }
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/DataStoreTests`

Expected: FAIL - "Value of type 'DataStore' has no member 'saveLastUsed'"

**Step 3: Write minimal implementation**

Add a new struct and methods to `Shared/Services/DataStore.swift`:

```swift
// Add at top of file after imports
private struct LastUsedInterval: Codable {
    let workDuration: TimeInterval
    let restDuration: TimeInterval
    let repetitions: Int
}

// Add to DataStore class
    private let userDefaults: UserDefaults
    private static let lastUsedKey = "lastUsedInterval"

    // Update init
    public init(modelContainer: ModelContainer, userDefaults: UserDefaults = .standard) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        self.userDefaults = userDefaults
    }

    public func saveLastUsed(_ interval: Interval) {
        let lastUsed = LastUsedInterval(
            workDuration: interval.workDuration,
            restDuration: interval.restDuration,
            repetitions: interval.repetitions
        )
        if let data = try? JSONEncoder().encode(lastUsed) {
            userDefaults.set(data, forKey: Self.lastUsedKey)
        }
    }

    public func loadLastUsed() -> Interval? {
        guard let data = userDefaults.data(forKey: Self.lastUsedKey),
              let lastUsed = try? JSONDecoder().decode(LastUsedInterval.self, from: data) else {
            return nil
        }
        return Interval(
            name: "",
            workDuration: lastUsed.workDuration,
            restDuration: lastUsed.restDuration,
            repetitions: lastUsed.repetitions
        )
    }
```

Update test setup to use isolated UserDefaults:

```swift
    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: Interval.self, configurations: config)
        let testDefaults = UserDefaults(suiteName: "test")!
        testDefaults.removePersistentDomain(forName: "test")
        dataStore = DataStore(modelContainer: modelContainer, userDefaults: testDefaults)
    }
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/DataStoreTests`

Expected: PASS - All 5 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/DataStore.swift ClimberTimerTests/Services/DataStoreTests.swift
git commit -m "feat(services): add last used persistence to DataStore - TDD

- RED: wrote tests for saveLastUsed and loadLastUsed
- GREEN: implemented UserDefaults-based last used storage
- Status: 29 tests passing, both platforms build"
```

---

## Task 12: FeedbackManager Service (TDD)

**Files:**
- Create: `Shared/Services/FeedbackManager.swift`
- Create: `ClimberTimerTests/Services/FeedbackManagerTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/Services/FeedbackManagerTests.swift`:

```swift
import XCTest
@testable import Shared

final class FeedbackManagerTests: XCTestCase {

    func test_should_play_audio_respects_settings() {
        var settings = FeedbackSettings(audioEnabled: true, visualEnabled: true, hapticsEnabled: true)
        var manager = FeedbackManager(settings: settings)

        XCTAssertTrue(manager.shouldPlayAudio)

        settings.audioEnabled = false
        manager = FeedbackManager(settings: settings)

        XCTAssertFalse(manager.shouldPlayAudio)
    }

    func test_should_show_visual_respects_settings() {
        var settings = FeedbackSettings(audioEnabled: true, visualEnabled: true, hapticsEnabled: true)
        var manager = FeedbackManager(settings: settings)

        XCTAssertTrue(manager.shouldShowVisual)

        settings.visualEnabled = false
        manager = FeedbackManager(settings: settings)

        XCTAssertFalse(manager.shouldShowVisual)
    }

    func test_should_trigger_haptics_respects_settings() {
        var settings = FeedbackSettings(audioEnabled: true, visualEnabled: true, hapticsEnabled: true)
        var manager = FeedbackManager(settings: settings)

        XCTAssertTrue(manager.shouldTriggerHaptics)

        settings.hapticsEnabled = false
        manager = FeedbackManager(settings: settings)

        XCTAssertFalse(manager.shouldTriggerHaptics)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/FeedbackManagerTests`

Expected: FAIL - "Cannot find 'FeedbackManager' in scope"

**Step 3: Write minimal implementation**

Create `Shared/Services/FeedbackManager.swift`:

```swift
import Foundation
import AVFoundation
#if os(iOS)
import CoreHaptics
#endif

public class FeedbackManager {
    private let settings: FeedbackSettings

    public var shouldPlayAudio: Bool { settings.audioEnabled }
    public var shouldShowVisual: Bool { settings.visualEnabled }
    public var shouldTriggerHaptics: Bool { settings.hapticsEnabled }

    public init(settings: FeedbackSettings) {
        self.settings = settings
    }

    public func playCountdownBeep() {
        guard shouldPlayAudio else { return }
        AudioServicesPlaySystemSound(1057) // Standard beep
    }

    public func playPhaseTransition() {
        guard shouldPlayAudio else { return }
        AudioServicesPlaySystemSound(1052) // Different tone
    }

    public func playCompletion() {
        guard shouldPlayAudio else { return }
        AudioServicesPlaySystemSound(1025) // Completion sound
    }

    public func triggerHaptic() {
        guard shouldTriggerHaptics else { return }
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }

    public func triggerStrongHaptic() {
        guard shouldTriggerHaptics else { return }
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
}
```

Note: Add missing imports at the top of the file:
```swift
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/FeedbackManagerTests`

Expected: PASS - All 3 tests pass

**Step 5: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 6: Commit**

```bash
git add Shared/Services/FeedbackManager.swift ClimberTimerTests/Services/FeedbackManagerTests.swift
git commit -m "feat(services): add FeedbackManager with TDD

- RED: wrote tests for settings-based feedback gating
- GREEN: implemented FeedbackManager with audio/haptic methods
- Status: 32 tests passing, both platforms build"
```

---

## Task 13: iOS HomeView

**Files:**
- Create: `ClimberTimer iOS/Views/HomeView.swift`
- Create: `ClimberTimer iOS/ViewModels/HomeViewModel.swift`
- Create: `ClimberTimerTests/ViewModels/HomeViewModelTests.swift`

**Step 1: Write the failing test for ViewModel**

Create `ClimberTimerTests/ViewModels/HomeViewModelTests.swift`:

```swift
import XCTest
import SwiftData
@testable import Shared
@testable import ClimberTimer_iOS

final class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    var dataStore: DataStore!
    var modelContainer: ModelContainer!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: Interval.self, configurations: config)
        let testDefaults = UserDefaults(suiteName: "test")!
        testDefaults.removePersistentDomain(forName: "test")
        dataStore = DataStore(modelContainer: modelContainer, userDefaults: testDefaults)
        viewModel = HomeViewModel(dataStore: dataStore)
    }

    func test_initial_values_are_defaults() {
        XCTAssertEqual(viewModel.workDuration, 7)
        XCTAssertEqual(viewModel.restDuration, 3)
        XCTAssertEqual(viewModel.repetitions, 6)
    }

    func test_loads_last_used_on_init() {
        let lastUsed = Interval(name: "", workDuration: 10, restDuration: 5, repetitions: 4)
        dataStore.saveLastUsed(lastUsed)

        viewModel = HomeViewModel(dataStore: dataStore)

        XCTAssertEqual(viewModel.workDuration, 10)
        XCTAssertEqual(viewModel.restDuration, 5)
        XCTAssertEqual(viewModel.repetitions, 4)
    }

    func test_create_interval_from_current_values() {
        viewModel.workDuration = 8
        viewModel.restDuration = 4
        viewModel.repetitions = 5

        let interval = viewModel.createInterval()

        XCTAssertEqual(interval.workDuration, 8)
        XCTAssertEqual(interval.restDuration, 4)
        XCTAssertEqual(interval.repetitions, 5)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/HomeViewModelTests`

Expected: FAIL - "No such module 'ClimberTimer_iOS'" or "Cannot find 'HomeViewModel'"

**Step 3: Write minimal ViewModel implementation**

Create `ClimberTimer iOS/ViewModels/HomeViewModel.swift`:

```swift
import Foundation
import SwiftUI
import Shared

@Observable
public class HomeViewModel {
    public var workDuration: TimeInterval = 7
    public var restDuration: TimeInterval = 3
    public var repetitions: Int = 6

    private let dataStore: DataStore

    public init(dataStore: DataStore) {
        self.dataStore = dataStore
        loadLastUsed()
    }

    private func loadLastUsed() {
        if let lastUsed = dataStore.loadLastUsed() {
            workDuration = lastUsed.workDuration
            restDuration = lastUsed.restDuration
            repetitions = lastUsed.repetitions
        }
    }

    public func createInterval() -> Interval {
        Interval(
            name: "",
            workDuration: workDuration,
            restDuration: restDuration,
            repetitions: repetitions
        )
    }

    public func saveAsLastUsed() {
        let interval = createInterval()
        dataStore.saveLastUsed(interval)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/HomeViewModelTests`

Expected: PASS - All 3 tests pass

**Step 5: Create the View**

Create `ClimberTimer iOS/Views/HomeView.swift`:

```swift
import SwiftUI
import Shared

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showingTimer = false
    @State private var showingPresets = false

    init(dataStore: DataStore) {
        _viewModel = State(initialValue: HomeViewModel(dataStore: dataStore))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Work Duration
                VStack {
                    Text("WORK")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper(
                        "\(Int(viewModel.workDuration))s",
                        value: $viewModel.workDuration,
                        in: 1...60,
                        step: 1
                    )
                    .font(.title)
                }

                // Rest Duration
                VStack {
                    Text("REST")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper(
                        "\(Int(viewModel.restDuration))s",
                        value: $viewModel.restDuration,
                        in: 1...60,
                        step: 1
                    )
                    .font(.title)
                }

                // Repetitions
                VStack {
                    Text("REPS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper(
                        "\(viewModel.repetitions)",
                        value: $viewModel.repetitions,
                        in: 1...20
                    )
                    .font(.title)
                }

                Spacer()

                // Start Button
                Button(action: {
                    viewModel.saveAsLastUsed()
                    showingTimer = true
                }) {
                    Text("START")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .padding()
            .navigationTitle("ClimberTimer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Presets") {
                        showingPresets = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showingTimer) {
                // ActiveTimerView will go here
                Text("Timer")
            }
            .sheet(isPresented: $showingPresets) {
                // PresetsListView will go here
                Text("Presets")
            }
        }
    }
}
```

**Step 6: Verify both platforms build**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add "ClimberTimer iOS/Views/HomeView.swift" "ClimberTimer iOS/ViewModels/HomeViewModel.swift" ClimberTimerTests/ViewModels/HomeViewModelTests.swift
git commit -m "feat(ios): add HomeView and HomeViewModel with TDD

- RED: wrote tests for initial values, last used loading, createInterval
- GREEN: implemented HomeViewModel and HomeView
- Status: 35 tests passing, iOS build succeeds"
```

---

## Task 14: iOS ActiveTimerView

**Files:**
- Create: `ClimberTimer iOS/Views/ActiveTimerView.swift`

**Step 1: Create the View**

Create `ClimberTimer iOS/Views/ActiveTimerView.swift`:

```swift
import SwiftUI
import Shared

struct ActiveTimerView: View {
    @State private var timer: IntervalTimer
    @State private var feedbackManager: FeedbackManager
    @Environment(\.dismiss) private var dismiss

    private let settings: FeedbackSettings

    init(interval: Interval, settings: FeedbackSettings) {
        self.settings = settings
        _timer = State(initialValue: IntervalTimer(interval: interval))
        _feedbackManager = State(initialValue: FeedbackManager(settings: settings))
    }

    var body: some View {
        ZStack {
            // Background color based on phase
            backgroundColor
                .ignoresSafeArea()
                .opacity(timer.isInCountdownWarning ? flashOpacity : 1)

            VStack(spacing: 24) {
                // Phase indicator
                Text(timer.currentPhase.displayName)
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.8))

                // Time remaining
                Text(TimeFormatting.format(timer.timeRemaining))
                    .font(.system(size: 96, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                // Rep counter
                Text("Rep \(timer.currentRep) of \(timer.totalReps)")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                // Controls
                HStack(spacing: 32) {
                    // Reset button
                    Button(action: { timer.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }

                    // Play/Pause button
                    Button(action: toggleTimer) {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Circle())
                    }

                    // Close button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
        .onAppear {
            timer.start()
        }
        .onChange(of: timer.isInCountdownWarning) { _, isWarning in
            if isWarning {
                feedbackManager.playCountdownBeep()
                feedbackManager.triggerHaptic()
            }
        }
        .onChange(of: timer.currentPhase) { _, _ in
            feedbackManager.playPhaseTransition()
            feedbackManager.triggerStrongHaptic()
        }
    }

    private var backgroundColor: Color {
        switch timer.currentPhase {
        case .work: return .green
        case .rest: return .blue
        case .finished: return .gray
        }
    }

    private var flashOpacity: Double {
        // Creates pulsing effect during countdown
        timer.isInCountdownWarning ? 0.7 : 1.0
    }

    private func toggleTimer() {
        if timer.isRunning {
            timer.pause()
        } else if timer.currentPhase == .finished {
            timer.reset()
            timer.start()
        } else {
            timer.resume()
        }
    }
}
```

**Step 2: Verify iOS builds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "ClimberTimer iOS/Views/ActiveTimerView.swift"
git commit -m "feat(ios): add ActiveTimerView

- Displays countdown with phase-colored background
- Shows controls for pause/resume/reset
- Triggers feedback on phase transitions and countdown warning
- Status: iOS build succeeds"
```

---

## Task 15: iOS PresetsListView

**Files:**
- Create: `ClimberTimer iOS/Views/PresetsListView.swift`
- Create: `ClimberTimer iOS/ViewModels/PresetsViewModel.swift`
- Create: `ClimberTimerTests/ViewModels/PresetsViewModelTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/ViewModels/PresetsViewModelTests.swift`:

```swift
import XCTest
import SwiftData
@testable import Shared
@testable import ClimberTimer_iOS

final class PresetsViewModelTests: XCTestCase {

    var viewModel: PresetsViewModel!
    var dataStore: DataStore!
    var modelContainer: ModelContainer!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: Interval.self, configurations: config)
        let testDefaults = UserDefaults(suiteName: "test")!
        testDefaults.removePersistentDomain(forName: "test")
        dataStore = DataStore(modelContainer: modelContainer, userDefaults: testDefaults)
        viewModel = PresetsViewModel(dataStore: dataStore)
    }

    func test_presets_initially_empty() {
        XCTAssertTrue(viewModel.presets.isEmpty)
    }

    func test_load_presets() throws {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        try dataStore.savePreset(interval)

        viewModel.loadPresets()

        XCTAssertEqual(viewModel.presets.count, 1)
        XCTAssertEqual(viewModel.presets.first?.name, "Test")
    }

    func test_delete_preset() throws {
        let interval = Interval(name: "To Delete", workDuration: 7, restDuration: 3, repetitions: 6)
        try dataStore.savePreset(interval)
        viewModel.loadPresets()

        viewModel.deletePreset(at: IndexSet(integer: 0))

        XCTAssertTrue(viewModel.presets.isEmpty)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/PresetsViewModelTests`

Expected: FAIL - "Cannot find 'PresetsViewModel'"

**Step 3: Write minimal ViewModel implementation**

Create `ClimberTimer iOS/ViewModels/PresetsViewModel.swift`:

```swift
import Foundation
import Shared

@Observable
public class PresetsViewModel {
    public var presets: [Interval] = []

    private let dataStore: DataStore

    public init(dataStore: DataStore) {
        self.dataStore = dataStore
        loadPresets()
    }

    public func loadPresets() {
        presets = dataStore.fetchPresets()
    }

    public func deletePreset(at offsets: IndexSet) {
        for index in offsets {
            let preset = presets[index]
            try? dataStore.deletePreset(preset)
        }
        loadPresets()
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/PresetsViewModelTests`

Expected: PASS - All 3 tests pass

**Step 5: Create the View**

Create `ClimberTimer iOS/Views/PresetsListView.swift`:

```swift
import SwiftUI
import Shared

struct PresetsListView: View {
    @State private var viewModel: PresetsViewModel
    @Environment(\.dismiss) private var dismiss

    let onSelect: (Interval) -> Void

    init(dataStore: DataStore, onSelect: @escaping (Interval) -> Void) {
        _viewModel = State(initialValue: PresetsViewModel(dataStore: dataStore))
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.presets, id: \.id) { preset in
                    Button(action: {
                        onSelect(preset)
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .font(.headline)
                            Text(preset.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.deletePreset)
            }
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .overlay {
                if viewModel.presets.isEmpty {
                    ContentUnavailableView(
                        "No Presets",
                        systemImage: "clock.badge.questionmark",
                        description: Text("Save your favorite intervals as presets")
                    )
                }
            }
        }
    }
}
```

**Step 6: Verify iOS builds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add "ClimberTimer iOS/Views/PresetsListView.swift" "ClimberTimer iOS/ViewModels/PresetsViewModel.swift" ClimberTimerTests/ViewModels/PresetsViewModelTests.swift
git commit -m "feat(ios): add PresetsListView and PresetsViewModel with TDD

- RED: wrote tests for empty state, load, delete
- GREEN: implemented PresetsViewModel and PresetsListView
- Status: 38 tests passing, iOS build succeeds"
```

---

## Task 16: iOS SettingsView

**Files:**
- Create: `ClimberTimer iOS/Views/SettingsView.swift`
- Create: `ClimberTimer iOS/ViewModels/SettingsViewModel.swift`
- Create: `ClimberTimerTests/ViewModels/SettingsViewModelTests.swift`

**Step 1: Write the failing test**

Create `ClimberTimerTests/ViewModels/SettingsViewModelTests.swift`:

```swift
import XCTest
@testable import Shared
@testable import ClimberTimer_iOS

final class SettingsViewModelTests: XCTestCase {

    func test_default_settings_all_enabled() {
        let viewModel = SettingsViewModel()

        XCTAssertTrue(viewModel.audioEnabled)
        XCTAssertTrue(viewModel.visualEnabled)
        XCTAssertTrue(viewModel.hapticsEnabled)
    }

    func test_to_feedback_settings() {
        let viewModel = SettingsViewModel()
        viewModel.audioEnabled = false

        let settings = viewModel.toFeedbackSettings()

        XCTAssertFalse(settings.audioEnabled)
        XCTAssertTrue(settings.visualEnabled)
        XCTAssertTrue(settings.hapticsEnabled)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/SettingsViewModelTests`

Expected: FAIL - "Cannot find 'SettingsViewModel'"

**Step 3: Write minimal implementation**

Create `ClimberTimer iOS/ViewModels/SettingsViewModel.swift`:

```swift
import Foundation
import Shared

@Observable
public class SettingsViewModel {
    public var audioEnabled: Bool = true
    public var visualEnabled: Bool = true
    public var hapticsEnabled: Bool = true

    public init() {}

    public func toFeedbackSettings() -> FeedbackSettings {
        FeedbackSettings(
            audioEnabled: audioEnabled,
            visualEnabled: visualEnabled,
            hapticsEnabled: hapticsEnabled
        )
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ClimberTimerTests/SettingsViewModelTests`

Expected: PASS - All 2 tests pass

**Step 5: Create the View**

Create `ClimberTimer iOS/Views/SettingsView.swift`:

```swift
import SwiftUI
import Shared

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Feedback") {
                    Toggle("Audio", isOn: $viewModel.audioEnabled)
                    Toggle("Visual", isOn: $viewModel.visualEnabled)
                    Toggle("Haptics", isOn: $viewModel.hapticsEnabled)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

**Step 6: Verify iOS builds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add "ClimberTimer iOS/Views/SettingsView.swift" "ClimberTimer iOS/ViewModels/SettingsViewModel.swift" ClimberTimerTests/ViewModels/SettingsViewModelTests.swift
git commit -m "feat(ios): add SettingsView and SettingsViewModel with TDD

- RED: wrote tests for default values and toFeedbackSettings
- GREEN: implemented SettingsViewModel and SettingsView
- Status: 40 tests passing, iOS build succeeds"
```

---

## Task 17: Wire Up iOS App

**Files:**
- Modify: `ClimberTimer iOS/App/ClimberTimerApp.swift`
- Modify: `ClimberTimer iOS/Views/HomeView.swift`

**Step 1: Update App entry point**

Update `ClimberTimer iOS/App/ClimberTimerApp.swift`:

```swift
import SwiftUI
import SwiftData
import Shared

@main
struct ClimberTimerApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Interval.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(modelContainer: modelContainer)
        }
        .modelContainer(modelContainer)
    }
}

struct ContentView: View {
    let modelContainer: ModelContainer
    @State private var dataStore: DataStore

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        _dataStore = State(initialValue: DataStore(modelContainer: modelContainer))
    }

    var body: some View {
        HomeView(dataStore: dataStore)
    }
}
```

**Step 2: Update HomeView to wire everything together**

Update `ClimberTimer iOS/Views/HomeView.swift` to include all navigation:

```swift
import SwiftUI
import Shared

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var settingsViewModel = SettingsViewModel()
    @State private var showingTimer = false
    @State private var showingPresets = false
    @State private var showingSettings = false

    private let dataStore: DataStore

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        _viewModel = State(initialValue: HomeViewModel(dataStore: dataStore))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Work Duration
                VStack {
                    Text("WORK")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper(
                        "\(Int(viewModel.workDuration))s",
                        value: $viewModel.workDuration,
                        in: 1...60,
                        step: 1
                    )
                    .font(.title)
                }

                // Rest Duration
                VStack {
                    Text("REST")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper(
                        "\(Int(viewModel.restDuration))s",
                        value: $viewModel.restDuration,
                        in: 1...60,
                        step: 1
                    )
                    .font(.title)
                }

                // Repetitions
                VStack {
                    Text("REPS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper(
                        "\(viewModel.repetitions)",
                        value: $viewModel.repetitions,
                        in: 1...20
                    )
                    .font(.title)
                }

                Spacer()

                // Start Button
                Button(action: {
                    viewModel.saveAsLastUsed()
                    showingTimer = true
                }) {
                    Text("START")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .padding()
            .navigationTitle("ClimberTimer")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Presets") {
                        showingPresets = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showingTimer) {
                ActiveTimerView(
                    interval: viewModel.createInterval(),
                    settings: settingsViewModel.toFeedbackSettings()
                )
            }
            .sheet(isPresented: $showingPresets) {
                PresetsListView(dataStore: dataStore) { preset in
                    viewModel.workDuration = preset.workDuration
                    viewModel.restDuration = preset.restDuration
                    viewModel.repetitions = preset.repetitions
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: settingsViewModel)
            }
        }
    }
}
```

**Step 3: Verify iOS builds and runs**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED

**Step 4: Run all tests**

Run:
```bash
xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: All tests pass

**Step 5: Commit**

```bash
git add "ClimberTimer iOS/"
git commit -m "feat(ios): wire up complete iOS app

- Connect HomeView with ActiveTimerView, PresetsListView, SettingsView
- Set up ModelContainer and DataStore in app entry point
- Status: 40 tests passing, iOS build succeeds"
```

---

## Task 18: watchOS Views

**Files:**
- Create: `ClimberTimer Watch/Views/WatchHomeView.swift`
- Create: `ClimberTimer Watch/Views/WatchActiveTimerView.swift`
- Create: `ClimberTimer Watch/Views/WatchPresetsView.swift`
- Modify: `ClimberTimer Watch/App/ClimberTimerWatchApp.swift`

**Step 1: Create WatchHomeView**

Create `ClimberTimer Watch/Views/WatchHomeView.swift`:

```swift
import SwiftUI
import Shared

struct WatchHomeView: View {
    @State private var workDuration: TimeInterval = 7
    @State private var restDuration: TimeInterval = 3
    @State private var repetitions: Int = 6
    @State private var showingTimer = false

    let dataStore: DataStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Work Duration
                    HStack {
                        Text("Work")
                        Spacer()
                        Text("\(Int(workDuration))s")
                            .foregroundStyle(.green)
                    }
                    .focusable()
                    .digitalCrownRotation($workDuration, from: 1, through: 60, by: 1)

                    // Rest Duration
                    HStack {
                        Text("Rest")
                        Spacer()
                        Text("\(Int(restDuration))s")
                            .foregroundStyle(.blue)
                    }
                    .focusable()
                    .digitalCrownRotation($restDuration, from: 1, through: 60, by: 1)

                    // Reps
                    HStack {
                        Text("Reps")
                        Spacer()
                        Text("\(repetitions)")
                    }
                    .focusable()
                    .digitalCrownRotation($repetitions, from: 1, through: 20, by: 1)

                    // Start Button
                    Button(action: { showingTimer = true }) {
                        Text("START")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    // Presets Link
                    NavigationLink("Presets") {
                        WatchPresetsView(dataStore: dataStore) { preset in
                            workDuration = preset.workDuration
                            restDuration = preset.restDuration
                            repetitions = preset.repetitions
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("ClimberTimer")
            .fullScreenCover(isPresented: $showingTimer) {
                WatchActiveTimerView(
                    interval: Interval(
                        name: "",
                        workDuration: workDuration,
                        restDuration: restDuration,
                        repetitions: repetitions
                    )
                )
            }
        }
        .onAppear {
            loadLastUsed()
        }
    }

    private func loadLastUsed() {
        if let lastUsed = dataStore.loadLastUsed() {
            workDuration = lastUsed.workDuration
            restDuration = lastUsed.restDuration
            repetitions = lastUsed.repetitions
        }
    }
}
```

**Step 2: Create WatchActiveTimerView**

Create `ClimberTimer Watch/Views/WatchActiveTimerView.swift`:

```swift
import SwiftUI
import WatchKit
import Shared

struct WatchActiveTimerView: View {
    @State private var timer: IntervalTimer
    @Environment(\.dismiss) private var dismiss

    init(interval: Interval) {
        _timer = State(initialValue: IntervalTimer(interval: interval))
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack {
                Text(timer.currentPhase.displayName)
                    .font(.caption)

                Text(TimeFormatting.format(timer.timeRemaining))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))

                Text("\(timer.currentRep)/\(timer.totalReps)")
                    .font(.caption)
            }
            .foregroundColor(.white)
        }
        .onAppear {
            timer.start()
        }
        .onTapGesture {
            if timer.isRunning {
                timer.pause()
            } else if timer.currentPhase == .finished {
                dismiss()
            } else {
                timer.resume()
            }
        }
        .onChange(of: timer.isInCountdownWarning) { _, isWarning in
            if isWarning {
                WKInterfaceDevice.current().play(.click)
            }
        }
        .onChange(of: timer.currentPhase) { _, newPhase in
            if newPhase == .finished {
                WKInterfaceDevice.current().play(.success)
            } else {
                WKInterfaceDevice.current().play(.start)
            }
        }
    }

    private var backgroundColor: Color {
        switch timer.currentPhase {
        case .work: return .green
        case .rest: return .blue
        case .finished: return .gray
        }
    }
}
```

**Step 3: Create WatchPresetsView**

Create `ClimberTimer Watch/Views/WatchPresetsView.swift`:

```swift
import SwiftUI
import Shared

struct WatchPresetsView: View {
    let dataStore: DataStore
    let onSelect: (Interval) -> Void

    @State private var presets: [Interval] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(presets, id: \.id) { preset in
            Button(action: {
                onSelect(preset)
                dismiss()
            }) {
                VStack(alignment: .leading) {
                    Text(preset.name)
                        .font(.headline)
                    Text(preset.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Presets")
        .onAppear {
            presets = dataStore.fetchPresets()
        }
    }
}
```

**Step 4: Update Watch App entry point**

Update `ClimberTimer Watch/App/ClimberTimerWatchApp.swift`:

```swift
import SwiftUI
import SwiftData
import Shared

@main
struct ClimberTimerWatchApp: App {
    let modelContainer: ModelContainer
    @State private var dataStore: DataStore

    init() {
        do {
            let container = try ModelContainer(for: Interval.self)
            modelContainer = container
            _dataStore = State(initialValue: DataStore(modelContainer: container))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            WatchHomeView(dataStore: dataStore)
        }
        .modelContainer(modelContainer)
    }
}
```

**Step 5: Verify watchOS builds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add "ClimberTimer Watch/"
git commit -m "feat(watch): add watchOS views

- WatchHomeView with Digital Crown controls
- WatchActiveTimerView with tap to pause/resume
- WatchPresetsView for browsing presets (read-only)
- Status: watchOS build succeeds"
```

---

## Task 19: Final Integration and Verification

**Step 1: Run all tests**

Run:
```bash
xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: All 40+ tests pass

**Step 2: Build both platforms**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

Expected: BUILD SUCCEEDED for both

**Step 3: Update PROGRESS.md**

Create `PROGRESS.md`:

```markdown
# ClimberTimer Implementation Progress

## Overall Status: COMPLETE

### Task 0: Xcode Project Setup - COMPLETE
- Created iOS + watchOS targets
- Configured App Groups
- Both platforms building

### Task 1-3: Models - COMPLETE
- Interval model with SwiftData
- FeedbackSettings struct
- TimerPhase enum
- 8 tests passing

### Task 4-8: IntervalTimer Service - COMPLETE
- Start/Pause/Resume/Reset
- Countdown logic with phase transitions
- 3-second countdown warning
- 12 tests passing

### Task 9: TimeFormatting - COMPLETE
- MM:SS format utility
- 4 tests passing

### Task 10-11: DataStore Service - COMPLETE
- Preset CRUD operations
- Last used persistence
- 5 tests passing

### Task 12: FeedbackManager - COMPLETE
- Audio/Visual/Haptic feedback
- Settings-based gating
- 3 tests passing

### Task 13-17: iOS Views - COMPLETE
- HomeView with steppers
- ActiveTimerView with phase colors
- PresetsListView with delete
- SettingsView with toggles
- 8 ViewModel tests passing

### Task 18: watchOS Views - COMPLETE
- WatchHomeView with Digital Crown
- WatchActiveTimerView with tap controls
- WatchPresetsView (read-only)
- Both platforms building

## Test Summary
- Total tests: 40+
- All passing
- Coverage: Models 90%+, Services 85%+

## Build Status
- iOS: BUILD SUCCEEDED
- watchOS: BUILD SUCCEEDED
- Warnings: 0
```

**Step 4: Commit**

```bash
git add PROGRESS.md
git commit -m "docs: add implementation progress tracking

All 19 tasks complete
40+ tests passing
Both iOS and watchOS building successfully"
```

---

## Summary

This plan implements ClimberTimer in 19 tasks with strict TDD:

1. **Tasks 0-3:** Project setup and models
2. **Tasks 4-8:** IntervalTimer service (core logic)
3. **Tasks 9-12:** Utilities and supporting services
4. **Tasks 13-17:** iOS views and ViewModels
5. **Task 18:** watchOS views
6. **Task 19:** Final integration

Each task follows RED-GREEN-REFACTOR with explicit verification steps.
