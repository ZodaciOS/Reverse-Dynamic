import UIKit

final class ProcessesViewController: UIViewController {
    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private var procs: [ProcInfo] = []
    private let refreshCtrl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Processes"
        view.backgroundColor = .systemGroupedBackground
        setupTable()
        loadProcesses()
    }

    private func setupTable() {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "proc")
        table.dataSource = self
        table.delegate = self
        table.refreshControl = refreshCtrl
        refreshCtrl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(openSettings))
    }

    @objc private func openSettings() {
        let s = SettingsViewController()
        let nav = UINavigationController(rootViewController: s)
        present(nav, animated: true)
    }

    @objc private func refresh() {
        loadProcesses()
    }

    private func loadProcesses() {
        IPCClient.shared.getJSON("/processes") { [weak self] (res: Result<[ProcInfo], IPCError>) in
            DispatchQueue.main.async {
                switch res {
                case .success(let arr):
                    self?.procs = arr
                    self?.table.reloadData()
                    self?.refreshCtrl.endRefreshing()
                case .failure(_):
                    MockProvider.shared.fetchProcesses { p in
                        self?.procs = p
                        self?.table.reloadData()
                        self?.refreshCtrl.endRefreshing()
                    }
                }
            }
        }
    }
}

extension ProcessesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { procs.count }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let p = procs[indexPath.row]
        let c = tv.dequeueReusableCell(withIdentifier: "proc", for: indexPath)
        c.textLabel?.text = "\(p.name)"
        c.detailTextLabel?.text = "PID: \(p.pid) • \(p.arch)"
        c.accessoryType = .disclosureIndicator
        return c
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let p = procs[indexPath.row]
        let mem = MemoryMapViewController(pid: p.pid, processName: p.name)
        navigationController?.pushViewController(mem, animated: true)
        tv.deselectRow(at: indexPath, animated: true)
    }
}
