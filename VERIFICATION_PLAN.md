# Verification Plan - Modal Button Contrast Fix (GitHub #11)

## Prerequisites

- [ ] Xcode installed and configured
- [ ] iOS Simulator available (iPhone 16)
- [ ] App builds successfully for iOS target
- [ ] All unit tests pass before starting verification

## Scenarios

### Scenario 1: Save Preset Dialog Readability

**Context**: App is running in iOS simulator, user is on the Timer Setup screen.

**Steps**:
1. Launch the app in iOS Simulator (iPhone 16)
2. Tap "New Timer" to navigate to Timer Setup screen
3. Take a screenshot BEFORE tapping "Save as Preset" (baseline)
4. Tap "Save as Preset" button
5. Take a screenshot of the dialog that appears
6. Observe the Cancel and Save button text colors
7. Verify text is clearly readable against the background
8. Type a preset name (e.g., "Test Preset")
9. Take a screenshot showing the enabled Save button
10. Tap Cancel to dismiss
11. Repeat steps 4-5 and tap Save to confirm it works

**Success Criteria**:
- [ ] Cancel button text is clearly visible (not red on dark gray)
- [ ] Save button text is clearly visible when enabled
- [ ] Save button appears visually distinct when disabled vs enabled
- [ ] Dialog background matches app theme (chalk/warm colors)
- [ ] Saving a preset actually saves it (appears in presets list)

**If Blocked**: If the simulator won't launch or the app crashes, stop and ask developer for help.

### Scenario 2: Delete Swipe Action Contrast Check

**Context**: App is running, user has at least one preset saved.

**Steps**:
1. Ensure at least one preset exists (save one if needed)
2. From Home screen, swipe left on a preset
3. Take a screenshot of the swipe action
4. Observe the Delete button styling
5. Verify the delete text/icon is readable

**Success Criteria**:
- [ ] Delete button is clearly visible (typically white on red)
- [ ] No contrast issues with the swipe action

**If Blocked**: If no presets exist and you cannot create one, the Save Preset scenario must pass first.

### Scenario 3: Full Flow Smoke Test

**Context**: Clean app state, testing the complete happy path.

**Steps**:
1. Launch fresh app instance
2. Tap "New Timer"
3. Adjust work duration (tap and pick a value)
4. Adjust rest duration (tap and pick a value)
5. Tap "Save as Preset"
6. Enter name "Verification Test"
7. Tap Save
8. Verify preset appears in list
9. Swipe to delete the test preset
10. Confirm deletion works

**Success Criteria**:
- [ ] All dialogs and buttons are readable throughout the flow
- [ ] Preset saves successfully
- [ ] Preset deletes successfully
- [ ] No visual regressions in other parts of the UI

**If Blocked**: Any crash or unexpected behavior should be documented and reported.

## Verification Rules

- Never use mocks or fakes - this tests the real running app
- Take screenshots at each key step for documentation
- If any success criterion fails, verification fails
- Ask developer for help if blocked, don't guess
- Screenshots should be saved to document before/after state

## Screenshot Naming Convention

Save screenshots to `.context/verification/` with names:
- `01-home-screen.png`
- `02-timer-setup.png`
- `03-save-dialog-empty.png`
- `04-save-dialog-with-name.png`
- `05-delete-swipe.png`
- `06-final-home.png`
