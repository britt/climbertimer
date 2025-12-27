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
