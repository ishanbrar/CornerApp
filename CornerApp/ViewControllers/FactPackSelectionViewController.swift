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
    
        override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Force dismiss any stuck alerts first
        if let presentedVC = presentedViewController {
            print("⚠️ Found stuck alert in viewDidAppear, dismissing")
            presentedVC.dismiss(animated: false)
        }

        // Load fact packs if they haven't been loaded yet
        if factPacks.isEmpty {
            print("📱 Loading fact packs in viewDidAppear")
            loadFactPacks()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Cancel any ongoing operations when leaving the view
        print("📱 FactPackSelectionViewController will disappear")
    }
    
    deinit {
        print("🗑️ FactPackSelectionViewController deallocated")
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup table view
        tableView.backgroundColor = UIColor.systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FactPackCell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 60
        
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
        // Check if view is loaded, but don't require window to be set yet
        guard isViewLoaded else {
            print("⚠️ View not loaded yet, will load fact packs in viewDidAppear")
            return
        }
        
        print("📱 Starting fact pack discovery...")
        
        // Show loading indicator only if view controller is properly in hierarchy
        let loadingAlert = UIAlertController(title: "Loading Fact Packs", message: "Discovering available fact packs...", preferredStyle: .alert)
        
        // Check if we can safely present the alert
        if isViewLoaded && view.window != nil {
            present(loadingAlert, animated: true)
        } else {
            print("⚠️ View controller not in hierarchy, skipping alert presentation")
            // Start discovery without showing alert
            factPackManager.discoverFactPacks { [weak self] discoveredPacks in
                DispatchQueue.main.async {
                    self?.updateFactPacksList(discoveredPacks)
                }
            }
            return
        }
        
        // Add a timeout to force dismiss the alert if it gets stuck
        let timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                print("⚠️ Force dismissing loading alert due to timeout")
                
                // Try multiple ways to dismiss the alert
                if let presentedVC = self.presentedViewController {
                    presentedVC.dismiss(animated: false) {
                        print("📱 Alert dismissed via presentedViewController")
                    }
                }
                
                // Also try to dismiss all presented view controllers
                self.dismiss(animated: false) {
                    print("📱 All presented view controllers dismissed")
                }
                
                // Update fact packs list regardless
                self.updateFactPacksList(["f1.json", "f2.json", "Earth.json"])
            }
        }
        
        // Set 5-second timeout as requested
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: timeoutWorkItem)
        
        factPackManager.discoverFactPacks { [weak self] discoveredPacks in
            DispatchQueue.main.async {
                print("📱 Fact pack discovery completed: \(discoveredPacks.count) packs found")
                
                // Cancel timeout since we completed successfully
                timeoutWorkItem.cancel()
                
                // Check if we're still in the view hierarchy before dismissing
                guard let self = self, self.isViewLoaded else {
                    print("⚠️ View controller no longer loaded, skipping dismiss")
                    return
                }
                
                // Force dismiss the alert immediately
                if self.presentedViewController == loadingAlert {
                    loadingAlert.dismiss(animated: true) {
                        print("📱 Loading alert dismissed successfully")
                        self.updateFactPacksList(discoveredPacks)
                    }
                } else {
                    print("⚠️ Loading alert not found, updating directly")
                    self.updateFactPacksList(discoveredPacks)
                }
            }
        }
    }
    
    private func updateFactPacksList(_ discoveredPacks: [String]) {
        print("📱 Updating fact packs list: \(discoveredPacks)")
        factPacks = discoveredPacks
        tableView.reloadData()
        
        if discoveredPacks.isEmpty {
            showNoFactPacksAlert()
        } else {
            print("✅ Fact packs loaded successfully: \(discoveredPacks)")
        }
    }
    
    private func showNoFactPacksAlert() {
        // Check if we're still in the view hierarchy
        guard isViewLoaded else {
            print("⚠️ View controller not loaded, skipping alert")
            return
        }
        
        let alert = UIAlertController(
            title: "No Fact Packs Found",
            message: "No fact packs were found in Firebase Storage. Please ensure JSON files are uploaded.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func switchToFactPack(_ factPackName: String) {
        // Check if we're still in the view hierarchy
        guard isViewLoaded else {
            print("⚠️ View controller not loaded, skipping fact pack switch")
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Switching Fact Pack", message: "Loading \(factPackName)...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        factPackManager.switchToFactPack(factPackName) { [weak self] success in
            DispatchQueue.main.async {
                // Check if we're still in the view hierarchy before dismissing
                guard let self = self, self.isViewLoaded else {
                    print("⚠️ View controller no longer loaded, skipping dismiss")
                    return
                }
                
                loadingAlert.dismiss(animated: true) {
                    if success {
                        // Show success message
                        let successAlert = UIAlertController(
                            title: "Fact Pack Switched",
                            message: "Successfully switched to \(factPackName)",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self.navigationController?.popViewController(animated: true)
                        })
                        self.present(successAlert, animated: true)
                    } else {
                        // Show error message
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "Failed to switch to \(factPackName). Please try again.",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
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
        
        // Get fact pack info with count
        factPackManager.getFactPackInfoWithCount(factPackName) { factPackInfo in
            DispatchQueue.main.async {
                // Configure cell with subtitle style
                cell.textLabel?.text = factPackInfo.name
                cell.detailTextLabel?.text = "\(factPackInfo.description) • \(factPackInfo.factCount) facts"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                cell.detailTextLabel?.textColor = UIColor.secondaryLabel
                
                // Show checkmark for current fact pack
                if factPackName == self.factPackManager.getCurrentFactPackName() {
                    cell.accessoryType = .checkmark
                    cell.textLabel?.textColor = UIColor.systemBlue
                } else {
                    cell.accessoryType = .none
                    cell.textLabel?.textColor = UIColor.label
                }
            }
        }
        
        // Set initial info while loading
        let initialInfo = factPackManager.getFactPackInfo(factPackName)
        cell.textLabel?.text = initialInfo.name
        cell.detailTextLabel?.text = "\(initialInfo.description) • Loading..."
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        cell.detailTextLabel?.textColor = UIColor.secondaryLabel
        
        // Show checkmark for current fact pack
        if factPackName == factPackManager.getCurrentFactPackName() {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.systemBlue
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.label
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