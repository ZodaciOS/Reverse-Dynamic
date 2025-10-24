import UIKit

class HostEntrypoint {
    static func attachOverlayIfNeeded(window: UIWindow) {
        OverlayController.shared.present(in: window)
    }
}
