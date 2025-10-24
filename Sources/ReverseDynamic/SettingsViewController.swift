import UIKit

final class SettingsViewController: UIViewController {
    private let hostField = UITextField()
    private let portField = UITextField()
    private let toggleMock = UISwitch()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
    }

    private func setupUI() {
        hostField.translatesAutoresizingMaskIntoConstraints = false
        hostField.placeholder = "Host"
        hostField.borderStyle = .roundedRect
        hostField.text = IPCClient.shared.host
        portField.translatesAutoresizingMaskIntoConstraints = false
        portField.placeholder = "Port"
        portField.borderStyle = .roundedRect
        portField.keyboardType = .numberPad
        portField.text = String(IPCClient.shared.port)
        toggleMock.translatesAutoresizingMaskIntoConstraints = false
        toggleMock.isOn = MockProvider.shared.fetchProcesses != nil
        let stack = UIStackView(arrangedSubviews: [hostField, portField, toggleMock])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
    }

    @objc private func save() {
        IPCClient.shared.host = hostField.text ?? IPCClient.shared.host
        if let p = Int(portField.text ?? "") { IPCClient.shared.port = p }
        dismiss(animated: true)
    }
}
