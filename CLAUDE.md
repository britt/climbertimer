# Project Rules for Claude - ClimberTimer

## Project Overview

Building a SwiftUI interval timer app for rock climbers. iPhone + Apple Watch with iCloud sync for presets.

## ABSOLUTE RULES - NO EXCEPTIONS

### 1. Test-Driven Development is MANDATORY

**The Iron Law**: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

Every single line of production code MUST follow this cycle:
1. **RED**: Write failing test FIRST
2. **Verify RED**: Run test, watch it fail for the RIGHT reason
3. **GREEN**: Write MINIMAL code to pass the test
4. **Verify GREEN**: Run test, confirm it passes
5. **REFACTOR**: Clean up with tests staying green

### 2. Violations = Delete and Start Over

If ANY of these occur, you MUST delete the code and start over:
- ❌ Wrote production code before test → DELETE CODE, START OVER
- ❌ Test passed immediately → TEST IS WRONG, FIX TEST FIRST
- ❌ Can't explain why test failed → NOT TDD, START OVER
- ❌ "I'll add tests later" → DELETE CODE NOW
- ❌ "Just this once without tests" → NO. DELETE CODE.
- ❌ "It's too simple to test" → NO. TEST FIRST.
- ❌ "Tests after achieve same goal" → NO. DELETE CODE.
- ❌ "SwiftUI views can't be tested" → TEST THE VIEW MODEL FIRST.

### 3. VERIFY COMPILATION BEFORE EVERY COMMIT

**MANDATORY**: Code MUST compile on BOTH platforms before committing.

**Pre-Commit Verification Checklist:**
1. ✅ Run iOS build - MUST succeed with zero errors
2. ✅ Run watchOS build - MUST succeed with zero errors
3. ✅ Run tests - ALL must pass
4. ✅ Zero compiler warnings

**Commands to run BEFORE every `git commit`:**

```bash
# 1. Build iOS (MUST pass)
xcodebuild build -scheme "ClimberTimer iOS" -destination 'platform=iOS Simulator,name=iPhone 15' | grep -E "(error:|warning:|BUILD)"

# 2. Build watchOS (MUST pass)
xcodebuild build -scheme "ClimberTimer Watch" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' | grep -E "(error:|warning:|BUILD)"

# 3. Run tests (ALL must pass)
xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' | grep -E "(error:|failed|passed|BUILD)"
```

**If ANY command fails → DO NOT COMMIT. Fix the issue first.**

Committing code that doesn't compile is NEVER acceptable. Not "just to save progress." Not "I'll fix it in the next commit." NEVER.

### 4. Test Coverage Requirements

- **Minimum 80%** coverage on business logic:
  - Models: 90%+
  - ViewModels/Services: 85%+
  - Timer Engine: 90%+
- UI views may have lower coverage but ViewModels must be thoroughly tested
- Untested code = Code that shouldn't exist

### 5. Before Writing ANY Code

Ask yourself:
1. Did I write a failing test for this?
2. Did I run the test and see it fail?
3. Did it fail for the expected reason?

If ANY answer is "no" → STOP. Write the test first.

### 6. Test File Structure

For every production file, there MUST be a corresponding test file:
- `Shared/Models/Interval.swift` → `ClimberTimerTests/Models/IntervalTests.swift`
- `Shared/Services/IntervalTimer.swift` → `ClimberTimerTests/Services/IntervalTimerTests.swift`
- `Shared/Services/DataStore.swift` → `ClimberTimerTests/Services/DataStoreTests.swift`
- `Shared/Services/FeedbackManager.swift` → `ClimberTimerTests/Services/FeedbackManagerTests.swift`

### 7. Task Completion Requirements

**MANDATORY RULE**: NO TASK IS COMPLETE until:
- ✅ ALL tests pass (100% green)
- ✅ Build succeeds for BOTH targets (iOS and watchOS) with ZERO errors
- ✅ NO compiler warnings
- ✅ Coverage meets minimum thresholds
- ✅ Progress documented in PROGRESS.md

A task with failing tests, build errors, or warnings is INCOMPLETE. Period.

### 8. Progress Documentation

**MANDATORY RULE**: YOU MUST REPORT YOUR PROGRESS IN `PROGRESS.md`

After completing EACH task:
1. Create `PROGRESS.md` if it doesn't exist
2. Document:
   - Task completed
   - Tests written/passed
   - Coverage achieved
   - Any issues encountered
   - Timestamp

Format:
```markdown
## Task X: [Name] - [COMPLETE/IN PROGRESS]
- Started: [timestamp]
- Tests: X passing, 0 failing
- Coverage: Lines: X%, Functions: X%
- Build iOS: ✅ Successful / ❌ Failed
- Build watchOS: ✅ Successful / ❌ Failed
- Warnings: ✅ Clean / ❌ X warnings
- Completed: [timestamp]
- Notes: [any relevant notes]
```

### 9. Git Commits - Commit Early, Commit Often

**MANDATORY RULE**: COMMIT EARLY, COMMIT OFTEN

- **Commit after EACH successful TDD cycle**:
  - ✅ After RED-GREEN-REFACTOR cycle completes
  - ✅ After each test file is created
  - ✅ After each module implementation
  - ✅ After fixing bugs or issues
  - ✅ After updating documentation

- **Frequency Requirements**:
  - Minimum: After each completed subtask
  - Maximum: No more than 30 minutes without a commit
  - Never have more than one feature in a single commit

- **Each commit MUST**:
  - Have failing tests written first
  - Pass all tests
  - Build successfully (both targets)
  - Have no compiler warnings
  - Meet coverage requirements (if code was added)
  - Have progress documented
  - Include clear commit message mentioning TDD

- **Commit Message Format**:
  ```
  type(scope): brief description

  - RED: What tests were written first
  - GREEN: What minimal code was added
  - Status: X tests passing, build successful
  - Coverage: X% (if applicable)
  ```

## Development Workflow

For EACH feature/function:

```
1. Write test file or add test case
2. Run: Cmd+U in Xcode OR swift test
3. See RED (test fails)
4. Understand WHY it fails
5. Write minimal production code
6. Run: Cmd+U OR swift test
7. See GREEN (test passes)
8. Refactor if needed
9. Run tests again (stays green)
10. Repeat for next feature
```

## Commands You'll Use Constantly

```bash
# Run all tests from command line
xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15'

# Build iOS target
xcodebuild build -scheme "ClimberTimer iOS" -destination 'platform=iOS Simulator,name=iPhone 15'

# Build watchOS target
xcodebuild build -scheme "ClimberTimer Watch" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'

# Run tests with coverage
xcodebuild test -scheme ClimberTimer -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
```

## Red Flags - STOP Immediately

If you catch yourself:
- Opening a .swift file before Tests.swift
- Writing function implementation before test
- Thinking "I know this works"
- Copying code from examples without tests
- Skipping test runs
- Ignoring failing tests
- Writing multiple features before testing
- "SwiftUI previews prove it works" (NO THEY DON'T)

**STOP. DELETE. START WITH TEST.**

## SwiftUI-Specific Testing Rules

### What MUST Be Tested (TDD)
- All Models (Interval, FeedbackSettings)
- All Services (IntervalTimer, DataStore, FeedbackManager)
- All ViewModels (@Observable classes)
- Business logic and state transitions
- Timer accuracy and phase transitions
- Data persistence and sync logic

### What Gets Integration/UI Tests
- View navigation flows
- User interaction sequences
- End-to-end timer sessions

### ViewModels Are The Key
- Every View that has logic gets a ViewModel
- ViewModel is tested with TDD
- View simply binds to ViewModel
- This makes SwiftUI testable

## The Mindset

- Tests are not optional
- Tests are not added after
- Tests DRIVE the implementation
- If it's not tested, it doesn't exist
- "But it's SwiftUI" is not an excuse

## Accountability Check

Before marking ANY task complete, verify:
1. ✓ Test written first?
2. ✓ Test failed first?
3. ✓ Minimal code to pass?
4. ✓ All tests green?
5. ✓ Coverage maintained?
6. ✓ iOS build succeeds?
7. ✓ watchOS build succeeds?
8. ✓ No compiler warnings?
9. ✓ Progress documented in PROGRESS.md?

Missing ANY ✓ = Task is NOT complete. Fix it first.

## Final Rule

**When in doubt**: Write a test.
**When not in doubt**: Write a test anyway.
**When it seems too simple**: Especially write a test.
**When it's "just UI"**: Test the ViewModel.

There are NO exceptions to TDD in this project. None.

---

*This document is your contract. Breaking these rules means breaking the project's core quality commitment. The discipline of TDD is what separates professional, reliable code from hopeful guesswork.*
