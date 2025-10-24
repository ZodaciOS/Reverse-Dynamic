import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var floating: FloatingToggleButton?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: ws)
        let main = MainTabBarController()
        window.rootViewController = main
        self.window = window
        window.makeKeyAndVisible()
        let fb = FloatingToggleButton(host: main)
        window.addSubview(fb)
        floating = fb
    }
}
