# Modal Button Contrast Fix - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix illegible button text in the Save Preset alert by replacing it with a custom dialog that has proper contrast matching the climbing theme.

**Architecture:** Replace SwiftUI's built-in `.alert()` with a custom sheet-based dialog that gives full control over button styling. Use AppColors.chalk for button text on colored backgrounds, ensuring legibility while matching the app's visual theme.

**Tech Stack:** SwiftUI, existing AppColors palette

---

## Background

**Issue:** GitHub #11 - Save Preset modal button text is illegible (red text on dark gray background)

**Root Cause:** SwiftUI's `.alert()` modifier uses system styling that conflicts with the app's granite tint color. The dark gray alert background combined with the inherited tint creates poor contrast.

**Solution:** Create a custom `SavePresetSheet` view with explicit color control. Use themed button styles with high contrast (chalk text on granite/woodlandGreen backgrounds).

**Files Involved:**
- `ClimberTimer iOS/Views/TimerSetupView.swift` - Replace `.alert()` with custom sheet
- `Shared/Views/SavePresetSheet.swift` - New custom dialog (create)
- `ClimberTimerTests/Views/SavePresetSheetTests.swift` - Tests for dialog behavior (create)

---

## Task 1: Create SavePresetSheet Tests

**Files:**
- Create: `ClimberTimerTests/Views/SavePresetSheetTests.swift`

**Step 1: Create test file with initial test**

```swift
import XCTest
@testable import ClimberTimer

final class SavePresetSheetTests: XCTestCase {

    func test_initialState_hasEmptyPresetName() {
        // Given/When
        let viewModel = SavePresetSheetViewModel()

        // Then
        XCTAssertEqual(viewModel.presetName, "")
    }
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ClimberTimerTests/SavePresetSheetTests 2>&1 | grep -E "(error:|Test Case|passed|failed)"
```
Expected: FAIL with "cannot find 'SavePresetSheetViewModel'"

**Step 3: Create minimal ViewModel to pass**

Create `Shared/ViewModels/SavePresetSheetViewModel.swift`:

```swift
import Foundation

@Observable
final class SavePresetSheetViewModel {
    var presetName: String = ""
}
```

**Step 4: Run test to verify it passes**

Run same command as Step 2.
Expected: PASS

**Step 5: Commit**

```bash
git add ClimberTimerTests/Views/SavePresetSheetTests.swift Shared/ViewModels/SavePresetSheetViewModel.swift
git commit -m "feat(modal): add SavePresetSheetViewModel with empty name test

- RED: Test for empty initial preset name
- GREEN: Created SavePresetSheetViewModel @Observable class
- Status: Tests passing, build successful

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Add Validation Tests for ViewModel

**Files:**
- Modify: `ClimberTimerTests/Views/SavePresetSheetTests.swift`
- Modify: `Shared/ViewModels/SavePresetSheetViewModel.swift`

**Step 1: Add test for save validation**

Add to `SavePresetSheetTests.swift`:

```swift
func test_canSave_returnsFalse_whenPresetNameIsEmpty() {
    // Given
    let viewModel = SavePresetSheetViewModel()

    // When
    viewModel.presetName = ""

    // Then
    XCTAssertFalse(viewModel.canSave)
}

func test_canSave_returnsFalse_whenPresetNameIsWhitespaceOnly() {
    // Given
    let viewModel = SavePresetSheetViewModel()

    // When
    viewModel.presetName = "   "

    // Then
    XCTAssertFalse(viewModel.canSave)
}

func test_canSave_returnsTrue_whenPresetNameHasContent() {
    // Given
    let viewModel = SavePresetSheetViewModel()

    // When
    viewModel.presetName = "My Preset"

    // Then
    XCTAssertTrue(viewModel.canSave)
}
```

**Step 2: Run tests to verify they fail**

Run:
```bash
xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ClimberTimerTests/SavePresetSheetTests 2>&1 | grep -E "(error:|Test Case|passed|failed)"
```
Expected: FAIL with "has no member 'canSave'"

**Step 3: Implement canSave computed property**

Update `SavePresetSheetViewModel.swift`:

```swift
import Foundation

@Observable
final class SavePresetSheetViewModel {
    var presetName: String = ""

    var canSave: Bool {
        !presetName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
```

**Step 4: Run tests to verify they pass**

Run same command as Step 2.
Expected: All PASS

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(modal): add canSave validation to SavePresetSheetViewModel

- RED: Tests for canSave with empty, whitespace, and valid names
- GREEN: Added canSave computed property with whitespace trimming
- Status: 4 tests passing, build successful

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Create SavePresetSheet View

**Files:**
- Create: `Shared/Views/SavePresetSheet.swift`

**Step 1: Create the custom sheet view with themed styling**

```swift
import SwiftUI

struct SavePresetSheet: View {
    @State private var viewModel = SavePresetSheetViewModel()
    let onSave: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter a name for your preset")
                    .font(.custom("AvenirNext-Regular", size: 17))
                    .foregroundStyle(AppColors.granite)

                TextField("Preset Name", text: $viewModel.presetName)
                    .font(.custom("AvenirNext-Medium", size: 17))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Save Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundStyle(AppColors.granite)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(viewModel.presetName)
                    }
                    .disabled(!viewModel.canSave)
                    .foregroundStyle(viewModel.canSave ? AppColors.woodlandGreen : AppColors.granite.opacity(0.5))
                }
            }
            .background(AppColors.chalk)
        }
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
}
```

**Step 2: Verify iOS build succeeds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|warning:|BUILD)"
```
Expected: BUILD SUCCEEDED

**Step 3: Verify watchOS build succeeds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' 2>&1 | grep -E "(error:|warning:|BUILD)"
```
Expected: BUILD SUCCEEDED

**Step 4: Run all tests**

Run:
```bash
xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|Test Case|passed|failed|BUILD)"
```
Expected: All tests pass

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(modal): create SavePresetSheet with themed button styling

- New custom sheet replaces system alert
- Cancel button: granite text for visibility
- Save button: woodlandGreen when enabled, muted when disabled
- chalk background for consistent app theme
- Status: All tests passing, both builds successful

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Update TimerSetupView to Use Custom Sheet

**Files:**
- Modify: `ClimberTimer iOS/Views/TimerSetupView.swift:175-190`

**Step 1: Replace .alert() with .sheet()**

Change lines 175-190 in `TimerSetupView.swift` from:

```swift
.alert("Save Preset", isPresented: $showingSavePreset) {
    TextField("Preset Name", text: $presetName)
    Button("Cancel", role: .cancel) { presetName = "" }
    Button("Save") {
        let name = presetName
        presetsViewModel.saveCurrentAsPreset(
            name: name,
            workDuration: viewModel.workDuration,
            restDuration: viewModel.restDuration,
            repetitions: viewModel.repetitions
        )
        viewModel.presetName = name
        savedPresetName = name
        presetName = ""
    }
}
```

To:

```swift
.sheet(isPresented: $showingSavePreset) {
    SavePresetSheet(
        onSave: { name in
            presetsViewModel.saveCurrentAsPreset(
                name: name,
                workDuration: viewModel.workDuration,
                restDuration: viewModel.restDuration,
                repetitions: viewModel.repetitions
            )
            viewModel.presetName = name
            savedPresetName = name
            showingSavePreset = false
        },
        onCancel: {
            showingSavePreset = false
        }
    )
}
```

**Step 2: Remove unused @State property**

Remove line 13 (`@State private var presetName = ""`) since the sheet now manages its own state.

**Step 3: Verify iOS build succeeds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|warning:|BUILD)"
```
Expected: BUILD SUCCEEDED

**Step 4: Verify watchOS build succeeds**

Run:
```bash
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' 2>&1 | grep -E "(error:|warning:|BUILD)"
```
Expected: BUILD SUCCEEDED

**Step 5: Run all tests**

Run:
```bash
xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|Test Case|passed|failed|BUILD)"
```
Expected: All tests pass

**Step 6: Commit**

```bash
git add -A
git commit -m "fix(modal): replace system alert with SavePresetSheet (#11)

- Removes illegible red-on-gray button text
- Uses themed colors: granite Cancel, woodlandGreen Save
- chalk background matches app aesthetic
- Fixes GitHub issue #11
- Status: All tests passing, both builds successful

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Verify Delete Swipe Action Contrast

**Files:**
- Review: `ClimberTimer iOS/Views/HomeView.swift:105-113`

**Step 1: Visually test the delete swipe action**

The delete swipe action uses `role: .destructive` which renders as red on the swipe background. This is a system-provided UI component that typically has good contrast.

Run the app and test:
1. Navigate to Home screen
2. Create a test preset if needed
3. Swipe left on a preset
4. Verify the "Delete" button is legible (white text on red background is system default)

**Step 2: Document finding**

If the delete button has good contrast (system default), no changes needed. The swipe action destructive styling is handled differently than alert buttons.

If it does NOT have good contrast, create a follow-up task.

**Step 3: Commit documentation update**

```bash
git add -A
git commit -m "docs: verify delete swipe action has acceptable contrast

- Swipe delete uses system destructive styling
- White text on red background - good contrast
- No changes needed for this component
- Status: Issue #11 fully addressed

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Update PROGRESS.md and Close Issue

**Files:**
- Modify: `PROGRESS.md`

**Step 1: Update PROGRESS.md**

Add section:

```markdown
## Task: Fix Modal Button Contrast (GitHub #11) - COMPLETE
- Started: [timestamp]
- Tests: All passing (SavePresetSheetTests added)
- Coverage: ViewModel fully tested
- Build iOS: ✅ Successful
- Build watchOS: ✅ Successful
- Warnings: ✅ Clean
- Completed: [timestamp]
- Notes: Replaced system .alert() with custom SavePresetSheet using themed colors (granite, woodlandGreen, chalk) for proper contrast.
```

**Step 2: Final verification**

Run full test suite and builds:
```bash
xcodebuild build -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(BUILD)"
xcodebuild build -scheme "ClimberTimer Watch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' 2>&1 | grep -E "(BUILD)"
xcodebuild test -scheme "ClimberTimer" -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(passed|failed)"
```

**Step 3: Final commit**

```bash
git add -A
git commit -m "docs: complete modal button contrast fix (#11)

- All tests passing
- Both iOS and watchOS builds successful
- PROGRESS.md updated
- Ready for PR

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Create SavePresetSheetViewModel with tests | New: ViewModel + Tests |
| 2 | Add canSave validation | Modify: ViewModel + Tests |
| 3 | Create SavePresetSheet view | New: View |
| 4 | Update TimerSetupView | Modify: TimerSetupView.swift |
| 5 | Verify delete swipe contrast | Review: HomeView.swift |
| 6 | Update docs and close | Modify: PROGRESS.md |

**Color Choices:**
- **Cancel button:** `AppColors.granite` - matches app theme, good contrast on chalk
- **Save button (enabled):** `AppColors.woodlandGreen` - action color, stands out
- **Save button (disabled):** `AppColors.granite.opacity(0.5)` - clearly inactive
- **Sheet background:** `AppColors.chalk` - warm, matches app aesthetic
- **Text:** `AppColors.granite` - consistent with app typography
