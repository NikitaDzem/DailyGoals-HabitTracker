import UIKit

class ailyGoalsAppDelegate: NSObject, UIApplicationDelegate {

    static var ailyGoalsOrientation = UIInterfaceOrientationMask.portrait {
        didSet {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return ailyGoalsAppDelegate.ailyGoalsOrientation
    }
}
