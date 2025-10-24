import UIKit

final class MainTabBarController: UITabBarController {
    private let overlayContainer = UIView()
    private lazy var overlayNav: UINavigationController = {
        let vc = ProcessesViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        return nav
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupOverlayContainer()
        observeOverlayToggle()
    }

    private func setupTabs() {
        view.backgroundColor = .systemBackground
        let processes = ProcessesViewController()
        processes.tabBarItem = UITabBarItem(title: "Processes", image: UIImage(systemName: "cpu"), tag: 0)
        let functions = FunctionsViewController()
        functions.tabBarItem = UITabBarItem(title: "Functions", image: UIImage(systemName: "function"), tag: 1)
        let memory = MemoryMapViewController()
        memory.tabBarItem = UITabBarItem(title: "Memory", image: UIImage(systemName: "memorychip"), tag: 2)
        let hex = HexViewerViewController()
        hex.tabBarItem = UITabBarItem(title: "Hex", image: UIImage(systemName: "doc.plaintext"), tag: 3)
        let snapshots = SnapshotsViewController()
        snapshots.tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(systemName: "clock.arrow.circlepath"), tag: 4)
        viewControllers = [wrap(processes), wrap(functions), wrap(memory), wrap(hex), wrap(snapshots)]
    }

    private func wrap(_ vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        vc.navigationItem.largeTitleDisplayMode = .automatic
        return nav
    }

    private func setupOverlayContainer() {
        overlayContainer.frame = view.bounds
        overlayContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.97)
        overlayContainer.isHidden = true
        overlayContainer.layer.shadowColor = UIColor.black.cgColor
        overlayContainer.layer.shadowOpacity = 0.18
        overlayContainer.layer.shadowRadius = 8
        view.addSubview(overlayContainer)
    }

    private func presentOverlay() {
        if overlayContainer.subviews.isEmpty {
            overlayNav.view.frame = overlayContainer.bounds
            overlayNav.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlayContainer.addSubview(overlayNav.view)
            addChild(overlayNav)
            overlayNav.didMove(toParent: self)
        }
        overlayContainer.alpha = 0
        overlayContainer.isHidden = false
        UIView.animate(withDuration: 0.22) { self.overlayContainer.alpha = 1 }
    }

    private func hideOverlay() {
        UIView.animate(withDuration: 0.18, animations: {
            self.overlayContainer.alpha = 0
        }) { _ in
            self.overlayContainer.isHidden = true
        }
    }

    private func observeOverlayToggle() {
        NotificationCenter.default.addObserver(self, selector: #selector(onShowOverlay), name: .toolOverlayShouldShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onHideOverlay), name: .toolOverlayShouldHide, object: nil)
    }

    @objc private func onShowOverlay() {
        presentOverlay()
    }

    @objc private func onHideOverlay() {
        hideOverlay()
    }
}
