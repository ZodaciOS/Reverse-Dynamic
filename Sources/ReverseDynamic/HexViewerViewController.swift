import UIKit

final class HexViewerViewController: UIViewController {
    private let textView = UITextView()
    private var pid: Int = 101
    private var addr: UInt64 = 0x100010000

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hex Viewer"
        view.backgroundColor = .systemBackground
        setupTextView()
        loadHex()
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
    }

    private func loadHex() {
        let size = 4096
        IPCClient.shared.getData("/process/\(pid)/mem", query: ["addr": String(addr), "size": String(size)]) { [weak self] res in
            DispatchQueue.main.async {
                switch res {
                case .success(let data):
                    self?.textView.text = self?.hexDump(data: data, base: self?.addr ?? 0)
                case .failure(_):
                    MockProvider.shared.fetchMemoryBytes(pid: self?.pid ?? 0, addr: self?.addr ?? 0, size: size) { d in
                        DispatchQueue.main.async {
                            self?.textView.text = self?.hexDump(data: d, base: self?.addr ?? 0)
                        }
                    }
                }
            }
        }
    }

    private func hexDump(data: Data, base: UInt64) -> String {
        var out = ""
        let bytes = [UInt8](data)
        let width = 16
        for row in 0..<((bytes.count + width - 1) / width) {
            let offset = row * width
            let lineBytes = bytes[offset..<min(offset+width, bytes.count)]
            let addr = base + UInt64(offset)
            out += String(format: "0x%016llx  ", addr)
            for b in lineBytes {
                out += String(format: "%02x ", b)
            }
            let pad = width - lineBytes.count
            if pad > 0 {
                out += String(repeating: "   ", count: pad)
            }
            out += "  "
            for b in lineBytes {
                if b >= 0x20 && b < 0x7f {
                    out += String(UnicodeScalar(b))
                } else {
                    out += "."
                }
            }
            out += "\n"
        }
        return out
    }
}
