import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var floatingBubbleManager: FloatingBubbleManager?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()

        floatingBubbleManager = FloatingBubbleManager.shared
        floatingBubbleManager?.start()

        UIApplication.shared.isIdleTimerDisabled = true
        beginInfiniteBackgroundTask()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        floatingBubbleManager?.keepBubbleAlive()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        floatingBubbleManager?.restoreBubbleIfNeeded()
    }

    private func beginInfiniteBackgroundTask() {
        _ = UIApplication.shared.beginBackgroundTask(withName: "BubbleTranslateAlive") {
            self.beginInfiniteBackgroundTask()
        }
    }
}
