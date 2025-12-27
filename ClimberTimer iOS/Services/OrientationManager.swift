import UIKit

@Observable
class OrientationManager {
    var allowedOrientations: UIInterfaceOrientationMask = .portrait

    func allowAllOrientations() {
        allowedOrientations = .all
    }

    func lockToPortrait() {
        allowedOrientations = .portrait
        // Force rotation back to portrait if currently in landscape
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
}
