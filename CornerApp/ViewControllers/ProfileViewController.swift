//
//  ProfileViewController.swift
//  CornerApp
//
//  Created by Jar Jar on 8/2/25.
//

import UIKit
protocol ProfileViewControllerDelegate: AnyObject {
    func didSelectFact(_ fact: Fact)
    func didSearchForEmoji(_ emoji: String)  // ← NEW
}
class ProfileViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var emailLabel: UILabel!
    private var cornerTapsLabel: UILabel!
    private var likedFactsTableView: UITableView!
    private var dislikedFactsTableView: UITableView!
    private var authButton: UIButton! // Changed from signOutButton to authButton
    private var likedFactsHeaderLabel: UILabel!
    private var dislikedFactsHeaderLabel: UILabel!
    private var notSignedInLabel: UILabel! // New label for when user is not signed in
    private var searchBar: UISearchBar!  // ← NEW
    private let firebaseManager = FirebaseManager.shared
    private var likedFacts: [Fact] = []
    private var dislikedFacts: [Fact] = []
    weak var delegate: ProfileViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUIForAuthState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIForAuthState() // Update UI based on auth state when view appears
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
        authButton = UIButton(type: .system) // Changed from signOutButton
        notSignedInLabel = UILabel() // New label
        
        //search bar
        searchBar = UISearchBar()  // ← NEW

        // Search Bar setup
        searchBar.placeholder = "Search by emoji(s)... 🔍 (e.g., 🇩🇪🎾)"  // ← UPDATED
        searchBar.delegate = self  // ← NEW
        searchBar.searchBarStyle = .minimal  // ← NEW
        searchBar.backgroundColor = UIColor.systemGray6  // ← NEW
        searchBar.layer.cornerRadius = 8  // ← NEW
        
        // Email Label
        emailLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emailLabel.textColor = UIColor.label
        emailLabel.numberOfLines = 0
        
        // Corner Taps Label
        cornerTapsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cornerTapsLabel.textColor = UIColor.secondaryLabel
        
        // Not Signed In Label
        notSignedInLabel.text = "Please sign in to view your profile data"
        notSignedInLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        notSignedInLabel.textColor = UIColor.secondaryLabel
        notSignedInLabel.textAlignment = .center
        notSignedInLabel.numberOfLines = 0
        
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
        
        // Auth Button (will be configured based on auth state)
        authButton.layer.cornerRadius = 8
        authButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        authButton.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
        
        // Add to view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(emailLabel)
        contentView.addSubview(cornerTapsLabel)
        contentView.addSubview(searchBar)  // ← ADDED THIS LINE
        contentView.addSubview(notSignedInLabel)
        contentView.addSubview(likedFactsHeaderLabel)
        contentView.addSubview(likedFactsTableView)
        contentView.addSubview(dislikedFactsHeaderLabel)
        contentView.addSubview(dislikedFactsTableView)
        contentView.addSubview(authButton)
        
        setupConstraints()
    }
    
    private func setupTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FactTableViewCell.self, forCellReuseIdentifier: "FactCell")
        tableView.backgroundColor = UIColor.systemGray6
        tableView.layer.cornerRadius = 8
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true // ✅ Must be true for independent scrolling
        tableView.showsVerticalScrollIndicator = true
    }

    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerTapsLabel.translatesAutoresizingMaskIntoConstraints = false
        notSignedInLabel.translatesAutoresizingMaskIntoConstraints = false
        likedFactsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        likedFactsTableView.translatesAutoresizingMaskIntoConstraints = false
        dislikedFactsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        dislikedFactsTableView.translatesAutoresizingMaskIntoConstraints = false
        authButton.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false  // ← NEW

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
            
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: cornerTapsLabel.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Not Signed In Label
            notSignedInLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            notSignedInLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notSignedInLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Liked Facts Header
            likedFactsHeaderLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            likedFactsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            likedFactsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Liked Facts Table View
            likedFactsTableView.topAnchor.constraint(equalTo: likedFactsHeaderLabel.bottomAnchor, constant: 10),
            likedFactsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            likedFactsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            likedFactsTableView.heightAnchor.constraint(equalToConstant: 200),
            // Currently fixed heights
          
            
            // Disliked Facts Header
            dislikedFactsHeaderLabel.topAnchor.constraint(equalTo: likedFactsTableView.bottomAnchor, constant: 30),
            dislikedFactsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dislikedFactsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Disliked Facts Table View
            dislikedFactsTableView.topAnchor.constraint(equalTo: dislikedFactsHeaderLabel.bottomAnchor, constant: 10),
            dislikedFactsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dislikedFactsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dislikedFactsTableView.heightAnchor.constraint(equalToConstant: 200),

            // Auth Button
            authButton.topAnchor.constraint(equalTo: dislikedFactsTableView.bottomAnchor, constant: 40),
            authButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            authButton.widthAnchor.constraint(equalToConstant: 200),
            authButton.heightAnchor.constraint(equalToConstant: 44),
            authButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }
    
    private func updateUIForAuthState() {
        let isSignedIn = firebaseManager.currentUser != nil
        
        if isSignedIn {
            // User is signed in - show profile data and sign out button
            loadUserData()
            configureSignOutButton()
            showSignedInContent()
        } else {
            // User is not signed in - show sign in button and hide profile data
            configureSignInButton()
            hideSignedInContent()
        }
    }
    
    private func configureSignInButton() {
        authButton.setTitle("Sign In", for: .normal)
        authButton.backgroundColor = UIColor.systemBlue
        authButton.tintColor = .white
    }
    
    private func configureSignOutButton() {
        authButton.setTitle("Sign Out", for: .normal)
        authButton.backgroundColor = UIColor.systemRed
        authButton.tintColor = .white
    }
    
    private func showSignedInContent() {
        emailLabel.isHidden = false
        cornerTapsLabel.isHidden = false
        searchBar.isHidden = false
        likedFactsHeaderLabel.isHidden = false
        likedFactsTableView.isHidden = false
        dislikedFactsHeaderLabel.isHidden = false
        dislikedFactsTableView.isHidden = false
        notSignedInLabel.isHidden = true
    }
    
    private func hideSignedInContent() {
        emailLabel.isHidden = true
        cornerTapsLabel.isHidden = true
        searchBar.isHidden = true
        likedFactsHeaderLabel.isHidden = true
        likedFactsTableView.isHidden = true
        dislikedFactsHeaderLabel.isHidden = true
        dislikedFactsTableView.isHidden = true
        notSignedInLabel.isHidden = false
    }
    
    private func loadUserData() {
        guard let profile = firebaseManager.userProfile else { return }
        
        emailLabel.text = "👤 \(profile.username) (\(profile.email))"
        cornerTapsLabel.text = "🎯 Corners: \(profile.cornerButtonTaps)"
        
        // Load liked and disliked facts
        likedFacts = firebaseManager.facts.filter { profile.likedFacts.contains($0.id) }
        dislikedFacts = firebaseManager.facts.filter { profile.dislikedFacts.contains($0.id) }
        
        // Update header labels with counts
        likedFactsHeaderLabel.text = "❤️ Liked Facts (\(likedFacts.count))"
        dislikedFactsHeaderLabel.text = "👎 Disliked Facts (\(dislikedFacts.count))"

        likedFactsTableView.reloadData()
        dislikedFactsTableView.reloadData()
    }
    
    // MARK: - Enhanced Search Functionality
    // MARK: - Enhanced Search Functionality
    // MARK: - Enhanced Search Functionality
    // MARK: - Enhanced Search Functionality
    // MARK: - Enhanced Search Functionality
    private func searchFactsByEmoji(_ searchText: String) {
        // Extract emojis from search text
        let emojis = extractEmojis(from: searchText)
        
        print("🔍 Search text: \(searchText)")
        print("🔍 Extracted emojis: \(emojis)")
        
        guard !emojis.isEmpty else {
            print("❌ No emojis found in search text")
            showNoResultsAlert()
            return
        }
        
        // First try: with variation selectors (original emojis)
        var matchingFacts = firebaseManager.facts.filter { fact in
            guard let factEmojis = fact.emojis else {
                return false
            }
            
            // Check if ALL searched emojis are present in the fact's emojis
            return emojis.allSatisfy { searchedEmoji in
                factEmojis.contains { factEmoji in
                    factEmoji.contains(searchedEmoji)
                }
            }
        }
        
        print("🔍 First try - Total matching facts: \(matchingFacts.count)")
        
        // If no results, try without variation selectors
        if matchingFacts.isEmpty {
            let cleanEmojis = emojis.map { emoji in
                emoji.replacingOccurrences(of: "\u{FE0F}", with: "")
            }
            
            print("🔍 Trying with clean emojis: \(cleanEmojis)")
            
            matchingFacts = firebaseManager.facts.filter { fact in
                guard let factEmojis = fact.emojis else {
                    return false
                }
                
                // Check if ALL searched emojis are present in the fact's emojis
                return cleanEmojis.allSatisfy { searchedEmoji in
                    factEmojis.contains { factEmoji in
                        factEmoji.contains(searchedEmoji)
                    }
                }
            }
            
            print("�� Second try - Total matching facts: \(matchingFacts.count)")
        }
        
        if let firstMatch = matchingFacts.first {
            delegate?.didSearchForEmoji(searchText)
            delegate?.didSelectFact(firstMatch)
            dismiss(animated: true)
        } else {
            showNoResultsAlert()
        }
    }
    
    private func extractEmojis(from text: String) -> [String] {
        // Handle flag emojis and other composed emojis properly
        var emojis: [String] = []
        
        // Split the text into grapheme clusters (complete emojis)
        let graphemeClusters = Array(text)
        
        for cluster in graphemeClusters {
            let emoji = String(cluster)
            if emoji.unicodeScalars.contains(where: { $0.properties.isEmoji }) && emojis.count < 3 {
                emojis.append(emoji)
            }
        }
        
        print("🔍 Extracted emojis: \(emojis)")
        return emojis
    }
    private func showNoResultsAlert() {
        let alert = UIAlertController(
            title: "No Results",
            message: "No facts found with those emojis. Try different emojis!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissProfile() {
        dismiss(animated: true)
    }
    
    @objc private func authButtonTapped(_ sender: UIButton) {
        let isSignedIn = firebaseManager.currentUser != nil
        
        if isSignedIn {
            // User is signed in - show sign out confirmation
            showSignOutConfirmation()
        } else {
            // User is not signed in - present authentication screen
            presentAuthenticationViewController()
        }
    }
    
    private func showSignOutConfirmation() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            do {
                try self?.firebaseManager.signOut()
                self?.dismissProfile()

            } catch {
                self?.showErrorAlert(message: "Failed to sign out. Please try again.")
            }
        })
        
        present(alert, animated: true)
    }
    
    private func presentAuthenticationViewController() {
        let authVC = AuthenticationViewController()
        authVC.modalPresentationStyle = .fullScreen
        
        present(authVC, animated: true) {
            print("🔥 Auth view controller presented from profile")
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension ProfileViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !searchText.isEmpty else { return }
        
        searchFactsByEmoji(searchText)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Optional: Add real-time search functionality here
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check which table view was tapped
        if tableView == likedFactsTableView {
            // Don't allow selection if no liked facts
            if likedFacts.isEmpty { return }
            let fact = likedFacts[indexPath.row]
            delegate?.didSelectFact(fact)
            dismiss(animated: true)
        } else if tableView == dislikedFactsTableView {
            // Don't allow selection if no disliked facts
            if dislikedFacts.isEmpty { return }
            let fact = dislikedFacts[indexPath.row]
            delegate?.didSelectFact(fact)
            dismiss(animated: true)
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
