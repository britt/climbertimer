# ClimberTimer - Design Document

Interval timing iOS app for rock climbers.

## Overview

ClimberTimer is a simple interval timer for hangboard training. Users configure work time, rest time, and repetitions, then run the timer with audio, visual, and haptic feedback. Presets sync between iPhone and Apple Watch via iCloud.

## MVP Scope

- Custom interval timer: work time, rest time, reps
- Feedback: audio, visual (with 3-second flash warning), haptics
- All feedback toggleable in settings, default on
- Save named presets
- Auto-remember last used settings
- iPhone + Apple Watch
- iCloud sync for presets

## Out of Scope (Future)

- General workout timer
- Route projecting timer
- Pre-built protocols (Eva Lopez, Lattice, etc.)
- Workout history/logging
- Social features

---

## Data Model

### Interval

The fundamental unit - a single timer configuration:

```swift
@Model
class Interval {
    var id: UUID
    var name: String
    var workDuration: TimeInterval  // seconds
    var restDuration: TimeInterval  // seconds
    var repetitions: Int
    var createdAt: Date
}
```

### FeedbackSettings

```swift
struct FeedbackSettings: Codable {
    var audioEnabled: Bool = true
    var visualEnabled: Bool = true
    var hapticsEnabled: Bool = true
}
```

### Storage

- Presets: SwiftData with CloudKit (automatic sync)
- Last used interval: UserDefaults with App Group (device-local)
- Feedback settings: UserDefaults with App Group

---

## Timer Engine

### IntervalTimer (ObservableObject)

Core properties:
- `currentPhase: Phase` - enum: `.work`, `.rest`, `.finished`
- `currentRep: Int` - which repetition (1-based)
- `timeRemaining: TimeInterval` - seconds left in current phase
- `isRunning: Bool`

### Flow

1. User taps Start - timer begins in `.work` phase
2. Work countdown reaches 0 - trigger feedback - switch to `.rest`
3. Rest countdown reaches 0 - increment rep - back to `.work`
4. After final rep's rest - `.finished` state with completion feedback

### Controls

- **Start** - begins the timer
- **Pause** - freezes countdown, remembers position
- **Resume** - continues from paused position
- **Reset** - stops and returns to beginning

### End-of-Phase Countdown (Final 3 Seconds)

All three feedback types sync together:
- **Visual:** Screen flashes/pulses each second
- **Audio:** Beep on each flash
- **Haptic:** Tap on each flash

### Background Execution

- Uses `BGTaskScheduler` for background audio/haptic cues
- Local notifications as fallback if app is killed
- Watch app runs independently (no phone connection required)

---

## iPhone UI

### 1. Home / Quick Start

- Shows last used interval settings ready to go
- Big "Start" button
- Tap any value to adjust inline
- "Save as Preset" button if settings differ from saved presets

### 2. Presets List

- List of saved intervals with name and summary (e.g., "7s / 3s x 6")
- Tap to select and load into Home
- Swipe to delete
- "+" to save current settings as new preset

### 3. Active Timer

- Large countdown display
- Phase indicator: "WORK" or "REST" with distinct colors (green/blue)
- Current rep: "Rep 3 of 6"
- Progress indicator
- Pause/Resume button (large)
- Reset button (smaller)
- Screen flashes during final 3 seconds

### 4. Settings

- Toggle: Audio feedback
- Toggle: Visual feedback
- Toggle: Haptics
- All default ON

---

## Apple Watch UI

Optimized for glanceability and minimal interaction.

### 1. Home

- Shows last used interval
- "Start" button front and center
- Scroll down for presets list
- Tap values to adjust via Digital Crown

### 2. Presets

- Simple scrollable list
- Tap to load and return to home
- No delete (phone only)
- No create (phone only)

### 3. Active Timer

- Large countdown number (fills screen)
- Color-coded background: green for work, blue for rest
- Small rep indicator: "3/6"
- Tap anywhere to pause/resume
- Force press or swipe for reset
- Full-screen color flash during final 3 seconds
- Strong haptic taps for all transitions

### Watch Behaviors

- Stays awake during active session (extended runtime session)
- Works independently - no iPhone needed during session
- Syncs presets when connectivity available

---

## Project Structure

```
ClimberTimer/
├── Shared/
│   ├── Models/
│   │   ├── Interval.swift
│   │   └── FeedbackSettings.swift
│   ├── Services/
│   │   ├── IntervalTimer.swift
│   │   ├── FeedbackManager.swift
│   │   └── DataStore.swift
│   └── Utilities/
│       └── TimeFormatting.swift
├── ClimberTimer iOS/
│   ├── App/
│   │   └── ClimberTimerApp.swift
│   └── Views/
│       ├── HomeView.swift
│       ├── PresetsListView.swift
│       ├── ActiveTimerView.swift
│       └── SettingsView.swift
├── ClimberTimer Watch/
│   ├── App/
│   │   └── ClimberTimerWatchApp.swift
│   └── Views/
│       ├── WatchHomeView.swift
│       ├── WatchPresetsView.swift
│       └── WatchActiveTimerView.swift
```

---

## Data Sync & Persistence

### SwiftData + CloudKit

- Automatic sync via SwiftData's CloudKit integration
- No manual sync - just works
- Conflict resolution: latest write wins
- Offline capable: changes queue until connectivity

### Last Used Tracking

- Stored in UserDefaults with App Group
- Not synced to cloud - device-local
- Instant save on every timer start

### App Group

- Shared container between iPhone and Watch
- Enables watch to access last-used before CloudKit syncs

### First Launch Defaults

- No presets
- Default values: 7s work / 3s rest / 6 reps

---

## Tech Stack

- SwiftUI (both platforms)
- SwiftData + CloudKit (preset sync)
- App Groups (shared UserDefaults)
- AVFoundation (audio feedback)
- Core Haptics / WatchKit haptics
