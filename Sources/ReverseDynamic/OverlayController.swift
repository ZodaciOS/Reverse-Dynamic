import UIKit

@MainActor
public final class OverlayController: @unchecked Sendable {
    public static let shared = OverlayController()
    private var hostWindow: UIWindow?
    private var containerVC: MainTabBarController?
    private var floatingButton: FloatingToggleButton?
    private var isPresented = false

    private init() {}

    public func present(in window: UIWindow) {
        guard !isPresented else { return }
        isPresented = true
        hostWindow = window
        let tab = MainTabBarController()
        tab.view.frame = window.bounds
        tab.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(tab.view)
        if let root = window.rootViewController {
            root.addChild(tab)
            tab.didMove(toParent: root)
        }
        containerVC = tab
        let fb = FloatingToggleButton(host: tab)
        window.addSubview(fb)
        floatingButton = fb
        NotificationCenter.default.addObserver(self, selector: #selector(hideOverlay), name: .toolOverlayShouldHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOverlay), name: .toolOverlayShouldShow, object: nil)
    }

    @objc private func hideOverlay() {
        guard let tab = containerVC else { return }
        UIView.animate(withDuration: 0.18) {
            tab.view.alpha = 0
        } completion: { _ in
            tab.view.isHidden = true
        }
        floatingButton?.isHidden = false
    }

    @objc private func showOverlay() {
        guard let tab = containerVC else { return }
        tab.view.isHidden = false
        UIView.animate(withDuration: 0.22) {
            tab.view.alpha = 1
        }
        floatingButton?.isHidden = true
    }

    public func dismiss() {
        guard isPresented else { return }
        isPresented = false
        containerVC?.willMove(toParent: nil)
        containerVC?.view.removeFromSuperview()
        containerVC?.removeFromParent()
        floatingButton?.removeFromSuperview()
        containerVC = nil
        floatingButton = nil
        hostWindow = nil
        NotificationCenter.default.removeObserver(self)
    }
}
