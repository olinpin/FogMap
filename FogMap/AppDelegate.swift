import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Instantiate the shared LocationManager so that location monitoring
        // continues even when the app is launched in the background due to
        // location updates.
        _ = LocationManager.shared
        return true
    }
}
