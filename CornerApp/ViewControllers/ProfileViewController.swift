//
//  ProfileViewController.swift
//  CornerApp
//
//  Created by Jar Jar on 8/2/25.
//


import UIKit

class ProfileViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var emailLabel: UILabel!
    private var cornerTapsLabel: UILabel!
    private var likedFactsTableView: UITableView!
    private var dislikedFactsTableView: UITableView!
    private var signOutButton: UIButton!
    private var likedFactsHeaderLabel: UILabel!
    private var dislikedFactsHeaderLabel: UILabel!
    
    private let firebaseManager = FirebaseManager.shared
    private var likedFacts: [Fact] = []
    private var dislikedFacts: [Fact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData() // Refresh data when view appears
    }
    
    private func setupUI() {
        title = "Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissProfile)
        )
        
        view.backgroundColor = UIColor.systemBackground
        
        // Initialize UI elements
        scrollView = UIScrollView()
        contentView = UIView()
        emailLabel = UILabel()
        cornerTapsLabel = UILabel()
        likedFactsHeaderLabel = UILabel()
        dislikedFactsHeaderLabel = UILabel()
        likedFactsTableView = UITableView()
        dislikedFactsTableView = UITableView()
        signOutButton = UIButton(type: .system)
        
        // Email Label
        emailLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emailLabel.textColor = UIColor.label
        emailLabel.numberOfLines = 0
        
        // Corner Taps Label
        cornerTapsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cornerTapsLabel.textColor = UIColor.secondaryLabel
        
        // Header Labels
        likedFactsHeaderLabel.text = "Liked Facts"
        likedFactsHeaderLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        likedFactsHeaderLabel.textColor = UIColor.systemRed
        
        dislikedFactsHeaderLabel.text = "Disliked Facts"
        dislikedFactsHeaderLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        dislikedFactsHeaderLabel.textColor = UIColor.systemGray
        
        // Table Views
        setupTableView(likedFactsTableView)
        setupTableView(dislikedFactsTableView)
        
        // Sign Out Button
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.backgroundColor = UIColor.systemRed
        signOutButton.tintColor = .white
        signOutButton.layer.cornerRadius = 8
        signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signOutButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        
        // Add to view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(emailLabel)
        contentView.addSubview(cornerTapsLabel)
        contentView.addSubview(likedFactsHeaderLabel)
        contentView.addSubview(likedFactsTableView)
        contentView.addSubview(dislikedFactsHeaderLabel)
        contentView.addSubview(dislikedFactsTableView)
        contentView.addSubview(signOutButton)
        
        setupConstraints()
    }
    
    private func setupTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FactTableViewCell.self, forCellReuseIdentifier: "FactCell")
        tableView.backgroundColor = UIColor.systemGray6
        tableView.layer.cornerRadius = 8
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = true
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerTapsLabel.translatesAutoresizingMaskIntoConstraints = false
        likedFactsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        likedFactsTableView.translatesAutoresizingMaskIntoConstraints = false
        dislikedFactsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        dislikedFactsTableView.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Corner Taps Label
            cornerTapsLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            cornerTapsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cornerTapsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Liked Facts Header
            likedFactsHeaderLabel.topAnchor.constraint(equalTo: cornerTapsLabel.bottomAnchor, constant: 30),
            likedFactsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            likedFactsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Liked Facts Table View
            likedFactsTableView.topAnchor.constraint(equalTo: likedFactsHeaderLabel.bottomAnchor, constant: 10),
            likedFactsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            likedFactsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            likedFactsTableView.heightAnchor.constraint(equalToConstant: 200),
            
            // Disliked Facts Header
            dislikedFactsHeaderLabel.topAnchor.constraint(equalTo: likedFactsTableView.bottomAnchor, constant: 30),
            dislikedFactsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dislikedFactsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Disliked Facts Table View
            dislikedFactsTableView.topAnchor.constraint(equalTo: dislikedFactsHeaderLabel.bottomAnchor, constant: 10),
            dislikedFactsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dislikedFactsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dislikedFactsTableView.heightAnchor.constraint(equalToConstant: 200),
            
            // Sign Out Button
            signOutButton.topAnchor.constraint(equalTo: dislikedFactsTableView.bottomAnchor, constant: 40),
            signOutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signOutButton.widthAnchor.constraint(equalToConstant: 200),
            signOutButton.heightAnchor.constraint(equalToConstant: 44),
            signOutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }
    
    private func loadUserData() {
        guard let profile = firebaseManager.userProfile else { return }
        
        emailLabel.text = "📧 \(profile.email)"
        cornerTapsLabel.text = "🎯 Corner Button Taps: \(profile.cornerButtonTaps)"
        
        // Load liked and disliked facts
        likedFacts = firebaseManager.facts.filter { profile.likedFacts.contains($0.id) }
        dislikedFacts = firebaseManager.facts.filter { profile.dislikedFacts.contains($0.id) }
        
        // Update header labels with counts
        likedFactsHeaderLabel.text = "❤️ Liked Facts (\(likedFacts.count))"
        dislikedFactsHeaderLabel.text = "💔 Disliked Facts (\(dislikedFacts.count))"
        
        likedFactsTableView.reloadData()
        dislikedFactsTableView.reloadData()
    }
    
    @objc private func dismissProfile() {
        dismiss(animated: true)
    }
    
    @objc private func signOutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            do {
                try self?.firebaseManager.signOut()
                self?.dismiss(animated: true)
            } catch {
                self?.showErrorAlert(message: "Failed to sign out. Please try again.")
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource and Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == likedFactsTableView {
            return likedFacts.isEmpty ? 1 : likedFacts.count
        } else {
            return dislikedFacts.isEmpty ? 1 : dislikedFacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FactCell", for: indexPath) as! FactTableViewCell
        
        if tableView == likedFactsTableView {
            if likedFacts.isEmpty {
                cell.configure(with: "No liked facts yet. Start exploring and like some facts!", isEmpty: true)
            } else {
                cell.configure(with: likedFacts[indexPath.row].text, isEmpty: false)
            }
        } else {
            if dislikedFacts.isEmpty {
                cell.configure(with: "No disliked facts yet.", isEmpty: true)
            } else {
                cell.configure(with: dislikedFacts[indexPath.row].text, isEmpty: false)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Custom Table View Cell
class FactTableViewCell: UITableViewCell {
    private let factLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        factLabel.numberOfLines = 0
        factLabel.font = UIFont.systemFont(ofSize: 14)
        factLabel.textColor = UIColor.label
        
        contentView.addSubview(factLabel)
        factLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            factLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            factLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            factLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            factLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with text: String, isEmpty: Bool) {
        factLabel.text = text
        factLabel.textColor = isEmpty ? UIColor.secondaryLabel : UIColor.label
        factLabel.font = isEmpty ? UIFont.italicSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        selectionStyle = isEmpty ? .none : .default
    }
}