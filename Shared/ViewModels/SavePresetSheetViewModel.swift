import Foundation

@Observable
final class SavePresetSheetViewModel {
    var presetName: String = ""

    var canSave: Bool {
        !presetName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
