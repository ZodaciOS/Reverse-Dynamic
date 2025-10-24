import UIKit

final class MemoryMapViewController: UIViewController {
    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private var regions: [MemRegion] = []
    private let pid: Int
    private let processName: String

    init(pid: Int, processName: String) {
        self.pid = pid
        self.processName = processName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Memory"
        view.backgroundColor = .systemGroupedBackground
        setupTable()
        loadMap()
    }

    private func setupTable() {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "mem")
        table.dataSource = self
        table.delegate = self
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadMap() {
        IPCClient.shared.getJSON("/process/\(pid)/memmap") { [weak self] (res: Result<[MemRegion], IPCError>) in
            DispatchQueue.main.async {
                switch res {
                case .success(let arr):
                    self?.regions = arr
                    self?.table.reloadData()
                case .failure(_):
                    MockProvider.shared.fetchMemoryMap(pid: self?.pid ?? 0) { r in
                        self?.regions = r
                        self?.table.reloadData()
                    }
                }
            }
        }
    }
}

extension MemoryMapViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { regions.count }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let r = regions[indexPath.row]
        let c = tv.dequeueReusableCell(withIdentifier: "mem", for: indexPath)
        let addrStr = String(format: "0x%llx", r.addr)
        c.textLabel?.text = "\(addrStr) size:\(r.size) perms:\(r.perms)"
        c.accessoryType = .disclosureIndicator
        return c
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let r = regions[indexPath.row]
        let vc = RegionDetailViewController(pid: pid, region: r)
        navigationController?.pushViewController(vc, animated: true)
        tv.deselectRow(at: indexPath, animated: true)
    }
}
