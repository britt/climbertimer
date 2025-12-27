import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationManager = OrientationManager()

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return Self.orientationManager.allowedOrientations
    }
}
