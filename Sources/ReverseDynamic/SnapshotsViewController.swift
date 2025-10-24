import UIKit

final class SnapshotsViewController: UIViewController {
    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private var snapshots: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sessions"
        view.backgroundColor = .systemGroupedBackground
        setupTable()
        loadSnapshots()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createSnapshot))
    }

    private func setupTable() {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "snap")
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

    private func loadSnapshots() {
        let fm = FileManager.default
        let docs = fm.temporaryDirectory
        let items = (try? fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil, options: [])) ?? []
        snapshots = items.filter { $0.pathExtension == "json" }
        table.reloadData()
    }

    @objc private func createSnapshot() {
        SnapshotManager.shared.createSnapshot(name: "snapshot") { [weak self] url in
            DispatchQueue.main.async {
                if let u = url {
                    self?.snapshots.insert(u, at: 0)
                    self?.table.reloadData()
                }
            }
        }
    }
}

extension SnapshotsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { snapshots.count }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let u = snapshots[indexPath.row]
        let c = tv.dequeueReusableCell(withIdentifier: "snap", for: indexPath)
        c.textLabel?.text = u.lastPathComponent
        c.accessoryType = .detailDisclosureButton
        return c
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let u = snapshots[indexPath.row]
        let ac = UIActivityViewController(activityItems: [u], applicationActivities: nil)
        present(ac, animated: true)
        tv.deselectRow(at: indexPath, animated: true)
    }
}
