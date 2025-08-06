import UIKit

class LikedFactsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let filterButton = UIButton(type: .system)
    private let firebaseManager = FirebaseManager.shared
    private let factPackManager = FactPackManager.shared
    
    private var allLikedFacts: [Fact] = []
    private var filteredLikedFacts: [Fact] = []
    private var availableFactPacks: [String] = []
    private var selectedFactPack: String? = nil // nil means "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLikedFacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Liked Facts"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup filter button with dark mode support
        filterButton.setTitle("Filter: All Fact Packs", for: .normal)
        filterButton.backgroundColor = UIColor.systemBlue
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.layer.cornerRadius = 8
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        // Setup table view with dark mode support
        tableView.backgroundColor = UIColor.systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LikedFactTableViewCell.self, forCellReuseIdentifier: "LikedFactCell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        view.addSubview(filterButton)
        view.addSubview(tableView)
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadLikedFacts() {
        // Load all facts and fact packs
        firebaseManager.loadAllFactsForProfile { [weak self] allFacts in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Get liked facts
                self.allLikedFacts = allFacts.filter { fact in
                    self.firebaseManager.isFactLiked(fact.id)
                }
                
                // Get available fact packs
                self.factPackManager.discoverFactPacks { factPacks in
                    DispatchQueue.main.async {
                        self.availableFactPacks = factPacks
                        self.applyFilter()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func applyFilter() {
        if let selectedFactPack = selectedFactPack {
            // Filter by specific fact pack
            filteredLikedFacts = allLikedFacts.filter { fact in
                fact.factPack == selectedFactPack
            }
        } else {
            // Show all liked facts
            filteredLikedFacts = allLikedFacts
        }
    }
    
    @objc private func filterButtonTapped() {
        let alert = UIAlertController(title: "Filter Fact Packs", message: "Choose a fact pack to filter by:", preferredStyle: .actionSheet)
        
        // Add "All" option
        alert.addAction(UIAlertAction(title: "All Fact Packs", style: .default) { [weak self] _ in
            self?.selectedFactPack = nil
            self?.updateFilterButtonTitle()
            self?.applyFilter()
            self?.tableView.reloadData()
        })
        
        // Add fact pack options
        for factPack in availableFactPacks {
            let packInfo = factPackManager.getFactPackInfo(factPack)
            alert.addAction(UIAlertAction(title: packInfo.name, style: .default) { [weak self] _ in
                self?.selectedFactPack = factPack
                self?.updateFilterButtonTitle()
                self?.applyFilter()
                self?.tableView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad, set the popover presentation
        if let popover = alert.popoverPresentationController {
            popover.sourceView = filterButton
            popover.sourceRect = filterButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func updateFilterButtonTitle() {
        if let selectedFactPack = selectedFactPack {
            let packInfo = factPackManager.getFactPackInfo(selectedFactPack)
            filterButton.setTitle("Filter: \(packInfo.name)", for: .normal)
        } else {
            filterButton.setTitle("Filter: All Fact Packs", for: .normal)
        }
    }
}

// MARK: - UITableViewDataSource
extension LikedFactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLikedFacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikedFactCell", for: indexPath) as! LikedFactTableViewCell
        let fact = filteredLikedFacts[indexPath.row]
        
        let factPackName = fact.factPack ?? "Unknown"
        let packInfo = factPackManager.getFactPackInfo(factPackName)
        
        cell.configure(with: fact, factPack: packInfo.name, isEmpty: false)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LikedFactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = filteredLikedFacts.count
        if let selectedFactPack = selectedFactPack {
            let packInfo = factPackManager.getFactPackInfo(selectedFactPack)
            return "\(packInfo.name) (\(count))"
        } else {
            return "All Liked Facts (\(count))"
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if filteredLikedFacts.isEmpty {
            if let selectedFactPack = selectedFactPack {
                let packInfo = factPackManager.getFactPackInfo(selectedFactPack)
                return "You haven't liked any facts from \(packInfo.name) yet."
            } else {
                return "You haven't liked any facts yet."
            }
        }
        return nil
    }
}

// MARK: - LikedFactTableViewCell
class LikedFactTableViewCell: UITableViewCell {
    private let factLabel = UILabel()
    private let factPackBadge = UILabel()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // Setup container view with dark mode support
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.1
        
        // Setup fact label with dark mode support
        factLabel.numberOfLines = 0
        factLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        factLabel.textColor = UIColor.label
        
        // Setup fact pack badge with dark mode support
        factPackBadge.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        factPackBadge.textColor = UIColor.white
        factPackBadge.backgroundColor = UIColor.systemBlue
        factPackBadge.layer.cornerRadius = 10
        factPackBadge.layer.masksToBounds = true
        factPackBadge.textAlignment = .center
        factPackBadge.numberOfLines = 1
        factPackBadge.adjustsFontSizeToFitWidth = true
        factPackBadge.minimumScaleFactor = 0.8
        
        contentView.addSubview(containerView)
        containerView.addSubview(factLabel)
        containerView.addSubview(factPackBadge)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        factLabel.translatesAutoresizingMaskIntoConstraints = false
        factPackBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            factPackBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            factPackBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            factPackBadge.heightAnchor.constraint(equalToConstant: 20),
            factPackBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            factPackBadge.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
            
            factLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            factLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            factLabel.trailingAnchor.constraint(equalTo: factPackBadge.leadingAnchor, constant: -8),
            factLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with fact: Fact, factPack: String, isEmpty: Bool) {
        factLabel.text = fact.text
        
        if isEmpty {
            containerView.backgroundColor = UIColor.systemGray6
            factLabel.textColor = UIColor.systemGray
            factPackBadge.isHidden = true
        } else {
            containerView.backgroundColor = UIColor.systemBackground
            factLabel.textColor = UIColor.label
            factPackBadge.isHidden = false
            factPackBadge.text = factPack
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update shadow opacity for dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.1
        }
    }
}

 