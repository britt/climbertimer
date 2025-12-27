# Picker Selection Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix GitHub #5 - users cannot select "1" on pickers because scroll snapping skips it.

**Architecture:** Replace custom `SilentWheelPicker` (which uses unreliable `scrollTargetBehavior(.viewAligned)`) with a `UIViewRepresentable` wrapper around `UIPickerView`. This provides native snapping and silent operation.

**Tech Stack:** SwiftUI, UIKit (UIPickerView), UIViewRepresentable

---

## Task 1: Create SilentPicker Component

**Files:**
- Create: `ClimberTimer iOS/Components/SilentPicker.swift`
- Test: `ClimberTimerTests/Components/SilentPickerTests.swift`

**Step 1: Create test file with first failing test**

Create `ClimberTimerTests/Components/SilentPickerTests.swift`:

```swift
import XCTest
@testable import ClimberTimer

final class SilentPickerCoordinatorTests: XCTestCase {

    func test_numberOfComponents_returnsOne() {
        let coordinator = SilentPickerCoordinator(
            selection: .constant(5),
            items: [1, 2, 3, 4, 5]
        )

        let picker = UIPickerView()
        let result = coordinator.numberOfComponents(in: picker)

        XCTAssertEqual(result, 1)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|SilentPicker|BUILD)"`

Expected: FAIL - `SilentPickerCoordinator` not found

**Step 3: Write minimal implementation**

Create `ClimberTimer iOS/Components/SilentPicker.swift`:

```swift
import SwiftUI
import UIKit

class SilentPickerCoordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    @Binding var selection: Int
    let items: [Int]

    init(selection: Binding<Int>, items: [Int]) {
        self._selection = selection
        self.items = items
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selection = items[row]
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = "\(items[row])"
        return NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont(name: "AvenirNext-Medium", size: 22) ?? .systemFont(ofSize: 22),
                .foregroundColor: UIColor(red: 92/255, green: 64/255, blue: 51/255, alpha: 1) // granite
            ]
        )
    }
}
```

**Step 4: Add test file to Xcode project**

Run: Add `ClimberTimerTests/Components/SilentPickerTests.swift` to the ClimberTimerTests target in Xcode.

**Step 5: Run test to verify it passes**

Run: `xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(Test Case|passed|failed)"`

Expected: PASS

**Step 6: Commit**

```bash
git add "ClimberTimer iOS/Components/SilentPicker.swift" "ClimberTimerTests/Components/SilentPickerTests.swift"
git commit -m "feat(picker): add SilentPickerCoordinator with TDD

- RED: test for numberOfComponents
- GREEN: minimal coordinator implementation
- Tests: 1 passing"
```

---

## Task 2: Add Coordinator Tests for Row Count and Selection

**Files:**
- Modify: `ClimberTimerTests/Components/SilentPickerTests.swift`

**Step 1: Add test for numberOfRowsInComponent**

Add to `SilentPickerCoordinatorTests`:

```swift
func test_numberOfRows_returnsItemCount() {
    let items = [0, 1, 2, 3, 4]
    let coordinator = SilentPickerCoordinator(
        selection: .constant(0),
        items: items
    )

    let picker = UIPickerView()
    let result = coordinator.pickerView(picker, numberOfRowsInComponent: 0)

    XCTAssertEqual(result, 5)
}

func test_didSelectRow_updatesSelection() {
    var selectedValue = 0
    let binding = Binding(
        get: { selectedValue },
        set: { selectedValue = $0 }
    )
    let coordinator = SilentPickerCoordinator(
        selection: binding,
        items: [10, 20, 30, 40, 50]
    )

    let picker = UIPickerView()
    coordinator.pickerView(picker, didSelectRow: 2, inComponent: 0)

    XCTAssertEqual(selectedValue, 30)
}
```

**Step 2: Run tests to verify they pass**

Run: `xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(Test Case|passed|failed)"`

Expected: All 3 tests PASS (implementation already handles these)

**Step 3: Commit**

```bash
git add "ClimberTimerTests/Components/SilentPickerTests.swift"
git commit -m "test(picker): add coordinator tests for row count and selection

- Tests: 3 passing"
```

---

## Task 3: Add UIViewRepresentable Wrapper

**Files:**
- Modify: `ClimberTimer iOS/Components/SilentPicker.swift`

**Step 1: Add SilentPicker struct**

Add to `SilentPicker.swift` after the Coordinator class:

```swift
struct SilentPicker: UIViewRepresentable {
    @Binding var selection: Int
    let items: [Int]

    func makeCoordinator() -> SilentPickerCoordinator {
        SilentPickerCoordinator(selection: $selection, items: items)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.backgroundColor = .clear
        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        if let index = items.firstIndex(of: selection) {
            if uiView.selectedRow(inComponent: 0) != index {
                uiView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
}
```

**Step 2: Build to verify compilation**

Run: `xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|BUILD)"`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "ClimberTimer iOS/Components/SilentPicker.swift"
git commit -m "feat(picker): add SilentPicker UIViewRepresentable wrapper

- Wraps UIPickerView for SwiftUI use
- Syncs selection binding bidirectionally"
```

---

## Task 4: Update DurationPickerView

**Files:**
- Modify: `ClimberTimer iOS/Views/DurationPickerView.swift`

**Step 1: Replace SilentWheelPicker with SilentPicker**

Replace lines 60-69 in `DurationPickerView.swift`:

```swift
// OLD (delete):
HStack(spacing: 0) {
    SilentWheelPicker(selection: $hours, items: Array(0..<24), cornerStyle: .left)
        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))

    SilentWheelPicker(selection: $minutes, items: Array(0..<60), cornerStyle: .none)
        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))

    SilentWheelPicker(selection: $seconds, items: Array(0..<60), cornerStyle: .right)
        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))
}

// NEW:
HStack(spacing: 0) {
    SilentPicker(selection: $hours, items: Array(0..<24))
        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))

    SilentPicker(selection: $minutes, items: Array(0..<60))
        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))

    SilentPicker(selection: $seconds, items: Array(0..<60))
        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))
}
```

**Step 2: Delete SilentWheelPicker and PickerCornerStyle**

Delete lines 97-186 (the `PickerCornerStyle` enum and `SilentWheelPicker` struct).

**Step 3: Build iOS to verify**

Run: `xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|BUILD)"`

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add "ClimberTimer iOS/Views/DurationPickerView.swift"
git commit -m "refactor(picker): replace SilentWheelPicker in DurationPickerView

- Use new SilentPicker (UIPickerView-based)
- Delete old SilentWheelPicker and PickerCornerStyle
- Fixes scroll snapping issue"
```

---

## Task 5: Update RepsPickerView

**Files:**
- Modify: `ClimberTimer iOS/Views/RepsPickerView.swift`

**Step 1: Replace SilentWheelPicker with SilentPicker**

Replace line 49 in `RepsPickerView.swift`:

```swift
// OLD (delete):
SilentWheelPicker(selection: $selectedReps, items: Array(1...20), cornerStyle: .all)
    .frame(width: 100, height: itemHeight * CGFloat(visibleItems))

// NEW:
SilentPicker(selection: $selectedReps, items: Array(1...20))
    .frame(width: 100, height: itemHeight * CGFloat(visibleItems))
```

**Step 2: Build iOS to verify**

Run: `xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|BUILD)"`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add "ClimberTimer iOS/Views/RepsPickerView.swift"
git commit -m "refactor(picker): replace SilentWheelPicker in RepsPickerView

- Use new SilentPicker (UIPickerView-based)
- Fixes scroll snapping issue for reps selection"
```

---

## Task 6: Build Both Targets and Run Tests

**Step 1: Build iOS**

Run: `xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|warning:|BUILD)"`

Expected: BUILD SUCCEEDED, no errors

**Step 2: Build watchOS**

Run: `xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' 2>&1 | grep -E "(error:|warning:|BUILD)"`

Expected: BUILD SUCCEEDED, no errors

**Step 3: Run all tests**

Run: `xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(Test Case|passed|failed|error:)"`

Expected: All tests pass

**Step 4: Update PROGRESS.md**

Create/update `PROGRESS.md`:

```markdown
## Task: Fix Picker Selection (GitHub #5) - COMPLETE
- Started: 2025-12-27
- Tests: All passing
- Build iOS: ✅ Successful
- Build watchOS: ✅ Successful
- Warnings: ✅ Clean
- Completed: 2025-12-27
- Notes: Replaced custom SilentWheelPicker with UIViewRepresentable wrapper around UIPickerView
```

**Step 5: Final commit**

```bash
git add PROGRESS.md
git commit -m "docs: update PROGRESS.md for picker fix completion"
```

---

## Manual Testing Checklist

After implementation, manually verify on simulator:

1. Open Duration picker → scroll to select 1 minute → verify it stays on 1
2. Open Duration picker → scroll to select 1 second → verify it stays on 1
3. Open Duration picker → scroll to select 1 hour → verify it stays on 1
4. Open Reps picker → scroll to select 1 rep → verify it stays on 1
5. Verify no click sound when scrolling pickers
