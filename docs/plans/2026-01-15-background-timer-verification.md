# Verification Plan: Background Timer & Notifications

> **For Claude:** Run these scenarios after completing the implementation. All scenarios must pass before marking the feature complete.

## Prerequisites

### Device Requirements
- [ ] Physical iPhone running iOS 17.0+ (Live Activity requires real device)
- [ ] iPhone must NOT be in Do Not Disturb or Focus mode
- [ ] Notification permissions granted for ClimberTimer app
- [ ] Live Activity permissions enabled (Settings > ClimberTimer > Live Activities)

### App Setup
- [ ] App built and installed via Xcode (Debug or Release)
- [ ] Fresh install recommended (delete app first to reset permissions)
- [ ] At least one saved preset in the app

### Test Timer Configuration
Use this configuration for all scenarios unless otherwise specified:
- **Work Duration:** 7 seconds
- **Rest Duration:** 3 seconds
- **Repetitions:** 3

This creates a timer of: 3s countdown + (7s + 3s) × 3 = 33 seconds total

### External Tools
- [ ] Stopwatch app or physical stopwatch for timing verification
- [ ] Screen recording enabled (optional, for evidence)

---

## Scenario 1: Timer Continues When App Backgrounded

**Context**: App is in foreground with timer running.

**Steps**:
1. Open ClimberTimer app
2. Start a new timer with test configuration (7s/3s/3 reps)
3. Start external stopwatch simultaneously
4. Wait for countdown to finish and first WORK phase to begin
5. Press Home button (or swipe up) to background the app
6. Wait 15 seconds (timer should progress through multiple phases)
7. Return to the app by tapping its icon

**Success Criteria**:
- [ ] Timer shows correct phase for elapsed time (should be in REST or WORK phase 2)
- [ ] Time remaining matches what elapsed on external stopwatch (±0.5 seconds tolerance)
- [ ] Rep counter shows correct value (should be rep 2 or 3)
- [ ] Timer continues running after returning to foreground

**If Blocked**: If app crashes on return, check console logs. If timer resets to beginning, state persistence is broken.

---

## Scenario 2: Notifications Fire on Phase Transitions

**Context**: App is backgrounded, timer is running.

**Steps**:
1. Start a new timer with test configuration
2. Immediately background the app after timer starts
3. Lock the phone screen
4. Wait and observe notifications

**Success Criteria**:
- [ ] Notification received when WORK phase 1 starts (after 3s countdown)
- [ ] Notification received when REST phase 1 starts (after 10s)
- [ ] Notification received when WORK phase 2 starts (after 13s)
- [ ] Notification received when REST phase 2 starts (after 20s)
- [ ] Notification received when WORK phase 3 starts (after 23s)
- [ ] Notification received when REST phase 3 starts (after 30s)
- [ ] Final notification received when timer FINISHES (after 33s)
- [ ] Each notification shows correct phase name ("WORK", "REST", or "Timer Complete")
- [ ] Each notification shows rep count where applicable

**If Blocked**: If no notifications appear, verify notification permissions in Settings. Check if Do Not Disturb is enabled.

---

## Scenario 3: Live Activity Displays on Lock Screen

**Context**: Timer is running, phone is locked.

**Steps**:
1. Start a new timer with test configuration
2. Lock the phone immediately after starting
3. View the lock screen

**Success Criteria**:
- [ ] Live Activity widget is visible on lock screen
- [ ] Widget shows current phase name (COUNTDOWN, WORK, REST)
- [ ] Widget shows countdown timer that updates in real-time
- [ ] Widget shows rep counter (e.g., "Rep 1/3")
- [ ] Widget background color changes with phase (orange→green→blue)
- [ ] When timer finishes, Live Activity disappears or shows "DONE"

**If Blocked**: Live Activity may not appear on simulator. Must test on physical device. Check Settings > ClimberTimer > Live Activities is enabled.

---

## Scenario 4: Dynamic Island Updates (iPhone 14 Pro+)

**Context**: Timer running on iPhone with Dynamic Island.

**Steps**:
1. Start a new timer with test configuration
2. Background the app
3. Observe Dynamic Island at top of screen

**Success Criteria**:
- [ ] Compact view shows phase indicator and countdown
- [ ] Long-press expands to show full timer details
- [ ] Phase color updates on transitions
- [ ] Countdown updates in real-time
- [ ] Tapping Dynamic Island opens the app

**If Blocked**: Only available on iPhone 14 Pro and later. Skip if testing on older device.

---

## Scenario 5: Zero Drift Timing Accuracy

**Context**: Timer runs entirely in background for full duration.

**Steps**:
1. Start external stopwatch
2. Start timer with test configuration (33s total)
3. Immediately background the app
4. Wait exactly 35 seconds on external stopwatch
5. Return to the app

**Success Criteria**:
- [ ] Timer shows FINISHED state (not still running)
- [ ] Timer finished within ±1 second of expected 33 seconds
- [ ] Final notification was received at correct time

**If Blocked**: If timer shows wrong phase, check PhaseSchedule calculations. If timer is still running, background restoration is broken.

---

## Scenario 6: Timer Persists Across App Termination

**Context**: App is force-quit while timer is running.

**Steps**:
1. Start a new timer with a longer configuration (7s/3s/6 reps = 63s total)
2. Start external stopwatch
3. Wait for timer to reach WORK phase 2 (~13 seconds)
4. Force-quit the app (swipe up from app switcher)
5. Wait 10 seconds
6. Relaunch the app

**Success Criteria**:
- [ ] App restores to active timer view (not home screen)
- [ ] Timer shows correct phase for total elapsed time
- [ ] Timer continues running from restored position
- [ ] Time remaining is accurate (±1 second tolerance)

**If Blocked**: If app opens to home screen, persistence load is failing. Check UserDefaults for saved state.

---

## Scenario 7: Paused Timer Stays Paused in Background

**Context**: Timer is paused before backgrounding.

**Steps**:
1. Start a new timer with test configuration
2. Wait for WORK phase 1 to begin
3. Tap pause button
4. Note the exact time remaining displayed
5. Background the app
6. Wait 30 seconds
7. Return to the app

**Success Criteria**:
- [ ] Timer is still paused
- [ ] Time remaining is EXACTLY what it was when paused (no drift)
- [ ] Phase is unchanged
- [ ] Tap play resumes timer correctly

**If Blocked**: If timer advanced while paused, pause state isn't being persisted correctly.

---

## Scenario 8: Timer Completes While Backgrounded

**Context**: Timer finishes entirely while app is in background.

**Steps**:
1. Start timer with test configuration (33s total)
2. Background the app immediately
3. Wait 60 seconds (well past timer completion)
4. Return to the app

**Success Criteria**:
- [ ] Timer shows FINISHED state
- [ ] "Timer Complete" notification was received
- [ ] Rep counter shows final rep count
- [ ] Live Activity has ended
- [ ] No crash or unexpected state

**If Blocked**: If timer shows mid-run state, finished detection in background restoration is broken.

---

## Scenario 9: Reset Cancels Notifications and Live Activity

**Context**: Timer is running with notifications scheduled.

**Steps**:
1. Start timer with longer configuration (7s/3s/6 reps)
2. Verify Live Activity appears
3. After 5 seconds, tap reset button
4. Tap close/X to dismiss timer view
5. Lock phone and wait 30 seconds

**Success Criteria**:
- [ ] Live Activity disappears immediately on reset
- [ ] NO notifications are received after reset
- [ ] App returns to home screen cleanly

**If Blocked**: If notifications still fire, cancelAllTimerNotifications is not being called on reset.

---

## Scenario 10: Start New Timer After Completion

**Context**: Previous timer has finished.

**Steps**:
1. Complete a full timer cycle (or reset after starting)
2. Return to home screen
3. Start a new timer with different configuration (10s/5s/2 reps)
4. Background the app
5. Wait for notifications

**Success Criteria**:
- [ ] New timer starts fresh (not continuing old timer)
- [ ] New Live Activity appears with correct configuration
- [ ] Notifications reflect new timer settings
- [ ] No remnants of previous timer state

**If Blocked**: If old timer state appears, persistence clear() is not being called.

---

## Scenario 11: Notification Permission Denied

**Context**: User has denied notification permissions.

**Steps**:
1. Go to Settings > ClimberTimer > Notifications
2. Disable all notification permissions
3. Return to app and start a timer
4. Background the app

**Success Criteria**:
- [ ] Timer runs normally (no crash)
- [ ] No notifications appear (expected)
- [ ] Live Activity still works (if enabled separately)
- [ ] Timer state restores correctly on return

**If Blocked**: If app crashes, notification manager isn't handling denied permissions gracefully.

---

## Scenario 12: Live Activity Disabled

**Context**: User has disabled Live Activity permissions.

**Steps**:
1. Go to Settings > ClimberTimer > Live Activities
2. Disable Live Activities
3. Return to app and start a timer
4. Lock phone

**Success Criteria**:
- [ ] Timer runs normally (no crash)
- [ ] No Live Activity appears on lock screen (expected)
- [ ] Notifications still work (if enabled)
- [ ] Timer state restores correctly

**If Blocked**: If app crashes, Live Activity manager isn't handling disabled state gracefully.

---

## Scenario 13: Long Timer Session

**Context**: Extended timer for realistic climbing workout.

**Steps**:
1. Create timer: 7s work, 53s rest, 6 reps (Eva Lopez-style repeaters)
2. Total duration: 3s + (7s + 53s) × 6 = 363s = ~6 minutes
3. Start timer and background app
4. Do NOT interact with phone for full 6 minutes
5. Return to app after timer should have finished

**Success Criteria**:
- [ ] Timer shows FINISHED state
- [ ] All phase notifications were received
- [ ] Live Activity ended cleanly
- [ ] No duplicate or missing notifications

**If Blocked**: If notifications are wrong, check phase calculation for longer rest periods.

---

## Verification Rules

| Rule | Enforcement |
|------|-------------|
| Physical device required | Live Activity won't work on simulator |
| No mocks or fakes | All tests use real notification center and ActivityKit |
| External timing | Use independent stopwatch for accuracy verification |
| Fresh app state | Reset app between scenarios if results seem wrong |
| All scenarios must pass | Partial success = verification failure |

---

## Verification Log Template

After running verification, document results:

```markdown
## Verification Log - [Date/Time]

### Device
- Model: [e.g., iPhone 15 Pro]
- iOS Version: [e.g., 17.2]
- Build: [Debug/Release, version]

### Results Summary
| Scenario | Status | Notes |
|----------|--------|-------|
| 1. Background Continue | PASS/FAIL | |
| 2. Notifications | PASS/FAIL | |
| 3. Live Activity Lock Screen | PASS/FAIL | |
| 4. Dynamic Island | PASS/FAIL/SKIP | |
| 5. Zero Drift | PASS/FAIL | |
| 6. App Termination | PASS/FAIL | |
| 7. Paused in Background | PASS/FAIL | |
| 8. Complete While Backgrounded | PASS/FAIL | |
| 9. Reset Cancels | PASS/FAIL | |
| 10. New Timer After Complete | PASS/FAIL | |
| 11. Notifications Denied | PASS/FAIL | |
| 12. Live Activity Disabled | PASS/FAIL | |
| 13. Long Session | PASS/FAIL | |

### Overall: PASS / FAIL

### Issues Found
- [List any problems discovered]

### Evidence
- [Screenshots, screen recordings, or logs attached]
```

---

## Blocking Issues - When to Stop

Stop verification and ask the developer if:

1. **App crashes** on any scenario - need crash logs
2. **Timing drift exceeds 2 seconds** - algorithm issue
3. **Notifications never appear** despite permissions granted - system issue
4. **Live Activity won't start** on physical device - entitlements issue
5. **Timer state doesn't persist** across app termination - persistence broken

Do NOT mark the feature complete until all 13 scenarios pass (Scenario 4 may be skipped if device lacks Dynamic Island).
