# Fix: Cannot Select 1 on Pickers

**Issue**: GitHub #5 - Picker aggressively scrolls to 0 or 2, skipping 1
**Branch**: `fix/picker-selection`
**Date**: 2025-12-27

## Root Cause

The custom `SilentWheelPicker` uses SwiftUI's `scrollTargetBehavior(.viewAligned)` which has unreliable snapping behavior, especially for items near the top of the list.

## Solution

Replace `SilentWheelPicker` with a `UIViewRepresentable` wrapper around `UIPickerView`. This provides:
- Native snapping behavior (fixes the bug)
- Direct control over sound
- Reliable selection

## Implementation

### New File: `Shared/Components/SilentPicker.swift`

```swift
SilentPicker<T: Hashable>
├── @Binding selection: T
├── items: [T]
├── formatter: (T) -> String
│
├── makeUIView() → UIPickerView
├── updateUIView() → sync selection
│
└── Coordinator
    ├── numberOfComponents → 1
    ├── numberOfRowsInComponent → items.count
    ├── attributedTitleForRow → styled text (AvenirNext-Medium 22pt, granite)
    └── didSelectRow → update binding
```

### Update: `DurationPickerView.swift`

- Replace 3 `SilentWheelPicker` calls with `SilentPicker`
- Remove `PickerCornerStyle` enum
- Remove manual selection indicator overlay
- Keep HStack layout with labels

### Update: `RepsPickerView.swift`

- Replace `SilentWheelPicker` with `SilentPicker`
- Items: `Array(1...20)`

### Delete

- `SilentWheelPicker` struct
- `PickerCornerStyle` enum

## Testing

Following TDD per CLAUDE.md:
1. Write tests for SilentPicker Coordinator logic (item count, selection binding)
2. Verify picker selection works for all values including 1
3. Build iOS and watchOS targets
