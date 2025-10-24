import UIKit

final class FunctionsViewController: UIViewController {
    private let table = UITableView(frame: .zero, style: .plain)
    private var functions: [FunctionInfo] = []
    private var filtered: [FunctionInfo] = []
    private let search = UISearchController(searchResultsController: nil)
    private var currentPID: Int? = 101

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Functions"
        view.backgroundColor = .systemBackground
        setupTable()
        setupSearch()
        loadFunctions()
    }

    private func setupTable() {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "fn")
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 56
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSearch() {
        navigationItem.searchController = search
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }

    private func loadFunctions() {
        guard let pid = currentPID else { return }
        IPCClient.shared.getJSON("/process/\(pid)/functions") { [weak self] (res: Result<[FunctionInfo], IPCError>) in
            DispatchQueue.main.async {
                switch res {
                case .success(let arr):
                    self?.functions = arr
                    self?.filtered = arr
                    self?.table.reloadData()
                case .failure(_):
                    MockProvider.shared.fetchFunctions(pid: pid) { f in
                        self?.functions = f
                        self?.filtered = f
                        self?.table.reloadData()
                    }
                }
            }
        }
    }
}

extension FunctionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { filtered.count }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fn = filtered[indexPath.row]
        let c = tv.dequeueReusableCell(withIdentifier: "fn", for: indexPath)
        c.textLabel?.text = "\(fn.name) 0x\(String(fn.addr, radix: 16))"
        c.detailTextLabel?.text = "size \(fn.size)"
        c.accessoryType = .disclosureIndicator
        return c
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
    }
}

extension FunctionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        if text.isEmpty {
            filtered = functions
        } else {
            filtered = functions.filter { $0.name.localizedCaseInsensitiveContains(text) }
        }
        table.reloadData()
    }
}
