import UIKit

public final class FloatingToggleButton: UIView {
    private let button = UIButton(type: .system)
    private var lastLocation: CGPoint = .zero
    private var panGesture: UIPanGestureRecognizer!
    private unowned let host: UIViewController
    private var isOpen: Bool = true

    public init(host: UIViewController) {
        self.host = host
        super.init(frame: CGRect(x: 18, y: 120, width: 56, height: 56))
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.95)
        layer.cornerRadius = 28
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 6
        clipsToBounds = false
        button.frame = bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let icon = UIImage(systemName: "menubar.rectangle", withConfiguration: config)
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(togglePressed), for: .touchUpInside)
        addSubview(button)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        addGestureRecognizer(panGesture)
        isAccessibilityElement = true
        accessibilityLabel = "Memory Explorer Toggle"
    }

    @objc private func togglePressed() {
        if isOpen {
            NotificationCenter.default.post(name: .toolOverlayShouldHide, object: nil)
        } else {
            NotificationCenter.default.post(name: .toolOverlayShouldShow, object: nil)
        }
        isOpen.toggle()
    }

    @objc private func panned(_ g: UIPanGestureRecognizer) {
        guard let sview = superview else { return }
        let translation = g.translation(in: sview)
        if g.state == .began {
            lastLocation = center
        }
        if g.state != .cancelled {
            center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
            center = snapToBounds(center)
        }
        if g.state == .ended {
            animateToNearestEdge()
        }
    }

    private func snapToBounds(_ p: CGPoint) -> CGPoint {
        guard let s = superview else { return p }
        let halfW = bounds.width / 2
        let halfH = bounds.height / 2
        let minX = halfW + 8
        let maxX = s.bounds.width - halfW - 8
        let minY = halfH + s.safeAreaInsets.top + 8
        let maxY = s.bounds.height - halfH - s.safeAreaInsets.bottom - 8
        return CGPoint(x: min(max(p.x, minX), maxX), y: min(max(p.y, minY), maxY))
    }

    private func animateToNearestEdge() {
        guard let s = superview else { return }
        let leftDist = center.x
        let rightDist = s.bounds.width - center.x
        let targetX: CGFloat = leftDist < rightDist ? (bounds.width/2 + 8) : (s.bounds.width - bounds.width/2 - 8)
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.78, initialSpringVelocity: 0.6, options: [], animations: {
            self.center.x = targetX
        })
    }
}

extension Notification.Name {
    public static let toolOverlayShouldHide = Notification.Name("toolOverlayShouldHide")
    public static let toolOverlayShouldShow = Notification.Name("toolOverlayShouldShow")
}
