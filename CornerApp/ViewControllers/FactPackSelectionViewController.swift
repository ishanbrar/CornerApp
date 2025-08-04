import UIKit

class FactPackSelectionViewController: UIViewController {
    
    private let tableView = UITableView()
    private let factPackManager = FactPackManager.shared
    private var factPacks: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFactPacks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Fact Packs"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup table view
        tableView.backgroundColor = UIColor.systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FactPackCell")
        tableView.separatorStyle = .singleLine
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadFactPacks() {
        factPacks = factPackManager.getAvailableFactPacks()
        tableView.reloadData()
    }
    
    private func switchToFactPack(_ factPackName: String) {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Switching Fact Pack", message: "Loading \(factPackName)...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        factPackManager.switchToFactPack(factPackName) { [weak self] success in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        // Show success message
                        let successAlert = UIAlertController(
                            title: "Fact Pack Switched",
                            message: "Successfully switched to \(factPackName)",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self?.navigationController?.popViewController(animated: true)
                        })
                        self?.present(successAlert, animated: true)
                    } else {
                        // Show error message
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "Failed to switch to \(factPackName). Please try again.",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension FactPackSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return factPacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FactPackCell", for: indexPath)
        let factPackName = factPacks[indexPath.row]
        let factPackInfo = factPackManager.getFactPackInfo(factPackName)
        
        cell.textLabel?.text = factPackInfo.name
        cell.detailTextLabel?.text = factPackInfo.description
        
        // Show checkmark for current fact pack
        if factPackName == factPackManager.getCurrentFactPackName() {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FactPackSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let factPackName = factPacks[indexPath.row]
        
        // Don't switch if it's already the current fact pack
        if factPackName == factPackManager.getCurrentFactPackName() {
            return
        }
        
        // Confirm fact pack switch
        let alert = UIAlertController(
            title: "Switch Fact Pack",
            message: "Are you sure you want to switch to \(factPackManager.getFactPackInfo(factPackName).name)? This will change the facts you see.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Switch", style: .default) { [weak self] _ in
            self?.switchToFactPack(factPackName)
        })
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Fact Packs"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Select a fact pack to change the facts you see in the app."
    }
} 