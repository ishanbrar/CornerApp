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
    private var activeFactPackLabel: UILabel! // New label for active fact pack
    private var selectFactPackButton: UIButton! // New button to select fact pack
    private var appearanceButton: UIButton! // New button to toggle appearance

    private var authButton: UIButton! // Changed from signOutButton to authButton
    private var likedFactsButton: UIButton! // Changed from label to button
    private var dislikedFactsButton: UIButton! // Changed from label to button
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
        updateActiveFactPackLabel() // Update active fact pack label
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
        activeFactPackLabel = UILabel() // New active fact pack label
        selectFactPackButton = UIButton(type: .system) // New select fact pack button
        appearanceButton = UIButton(type: .system) // New appearance toggle button
        likedFactsButton = UIButton(type: .system) // Changed from label to button
        dislikedFactsButton = UIButton(type: .system) // Changed from label to button

        authButton = UIButton(type: .system) // Changed from signOutButton
        notSignedInLabel = UILabel() // New label
        
        //search bar
        searchBar = UISearchBar()  // ← NEW

        // Search Bar setup with dark mode support
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
        
        // Active Fact Pack Label
        activeFactPackLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        activeFactPackLabel.textColor = UIColor.systemBlue
        activeFactPackLabel.textAlignment = .left
        activeFactPackLabel.numberOfLines = 1
        
        // Enhanced Select Fact Pack Button
        selectFactPackButton.setTitle("📚 Change Fact Pack", for: .normal)
        selectFactPackButton.backgroundColor = UIColor.systemBlue
        selectFactPackButton.setTitleColor(.white, for: .normal)
        selectFactPackButton.layer.cornerRadius = 12
        selectFactPackButton.layer.shadowColor = UIColor.black.cgColor
        selectFactPackButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectFactPackButton.layer.shadowRadius = 4
        selectFactPackButton.layer.shadowOpacity = 0.2
        selectFactPackButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        selectFactPackButton.addTarget(self, action: #selector(selectFactPackButtonTapped), for: .touchUpInside)
        
        // Enhanced Appearance Toggle Button
        updateAppearanceButton()
        appearanceButton.layer.cornerRadius = 12
        appearanceButton.layer.shadowColor = UIColor.black.cgColor
        appearanceButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        appearanceButton.layer.shadowRadius = 4
        appearanceButton.layer.shadowOpacity = 0.2
        appearanceButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        appearanceButton.addTarget(self, action: #selector(appearanceButtonTapped), for: .touchUpInside)
        
        // Not Signed In Label
        notSignedInLabel.text = "Please sign in to view your profile data"
        notSignedInLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        notSignedInLabel.textColor = UIColor.secondaryLabel
        notSignedInLabel.textAlignment = .center
        notSignedInLabel.numberOfLines = 0
        
        // Liked Facts Button
        likedFactsButton.setTitle("❤️ Liked Facts", for: .normal)
        likedFactsButton.backgroundColor = UIColor.systemRed
        likedFactsButton.setTitleColor(.white, for: .normal)
        likedFactsButton.layer.cornerRadius = 12
        likedFactsButton.layer.shadowColor = UIColor.black.cgColor
        likedFactsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        likedFactsButton.layer.shadowRadius = 4
        likedFactsButton.layer.shadowOpacity = 0.2
        likedFactsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        likedFactsButton.addTarget(self, action: #selector(likedFactsButtonTapped), for: .touchUpInside)
        
        // Disliked Facts Button
        dislikedFactsButton.setTitle("👎 Disliked Facts", for: .normal)
        dislikedFactsButton.backgroundColor = UIColor.systemGray
        dislikedFactsButton.setTitleColor(.white, for: .normal)
        dislikedFactsButton.layer.cornerRadius = 12
        dislikedFactsButton.layer.shadowColor = UIColor.black.cgColor
        dislikedFactsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        dislikedFactsButton.layer.shadowRadius = 4
        dislikedFactsButton.layer.shadowOpacity = 0.2
        dislikedFactsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        dislikedFactsButton.addTarget(self, action: #selector(dislikedFactsButtonTapped), for: .touchUpInside)
        

        
        // Auth Button (will be configured based on auth state) with dark mode support
        authButton.layer.cornerRadius = 8
        authButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        authButton.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
        
        // Fact Pack Button with dark mode support - removed from bottom, now integrated with appearance button
        
        // Add to view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add all subviews to contentView
        contentView.addSubview(searchBar)  // Search bar at the top
        contentView.addSubview(emailLabel)
        contentView.addSubview(cornerTapsLabel)
        contentView.addSubview(activeFactPackLabel)
        contentView.addSubview(selectFactPackButton)
        contentView.addSubview(appearanceButton)
        contentView.addSubview(notSignedInLabel)
        contentView.addSubview(likedFactsButton)
        contentView.addSubview(dislikedFactsButton)
        contentView.addSubview(authButton)
        
        // Setup constraints after all views are added to hierarchy
        setupConstraints()
    }
    


    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerTapsLabel.translatesAutoresizingMaskIntoConstraints = false
        notSignedInLabel.translatesAutoresizingMaskIntoConstraints = false
        activeFactPackLabel.translatesAutoresizingMaskIntoConstraints = false
        selectFactPackButton.translatesAutoresizingMaskIntoConstraints = false
        appearanceButton.translatesAutoresizingMaskIntoConstraints = false
        likedFactsButton.translatesAutoresizingMaskIntoConstraints = false
        dislikedFactsButton.translatesAutoresizingMaskIntoConstraints = false
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
            
            // Search Bar at the top
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Corner Taps Label
            cornerTapsLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            cornerTapsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cornerTapsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Active Fact Pack Label
            activeFactPackLabel.topAnchor.constraint(equalTo: cornerTapsLabel.bottomAnchor, constant: 10),
            activeFactPackLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activeFactPackLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Select Fact Pack Button
            selectFactPackButton.topAnchor.constraint(equalTo: activeFactPackLabel.bottomAnchor, constant: 30),
            selectFactPackButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectFactPackButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectFactPackButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Appearance Button
            appearanceButton.topAnchor.constraint(equalTo: selectFactPackButton.bottomAnchor, constant: 20),
            appearanceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            appearanceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            appearanceButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Not Signed In Label
            notSignedInLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            notSignedInLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notSignedInLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Liked Facts Button
            likedFactsButton.topAnchor.constraint(equalTo: appearanceButton.bottomAnchor, constant: 30),
            likedFactsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            likedFactsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            likedFactsButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Disliked Facts Button
            dislikedFactsButton.topAnchor.constraint(equalTo: likedFactsButton.bottomAnchor, constant: 20),
            dislikedFactsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dislikedFactsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dislikedFactsButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Auth Button
            authButton.topAnchor.constraint(equalTo: dislikedFactsButton.bottomAnchor, constant: 40),
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
        searchBar.isHidden = false
        emailLabel.isHidden = false
        cornerTapsLabel.isHidden = false
        activeFactPackLabel.isHidden = false
        selectFactPackButton.isHidden = false
        appearanceButton.isHidden = false
        likedFactsButton.isHidden = false
        dislikedFactsButton.isHidden = false
        notSignedInLabel.isHidden = true
    }
    
    private func hideSignedInContent() {
        searchBar.isHidden = true
        emailLabel.isHidden = true
        cornerTapsLabel.isHidden = true
        activeFactPackLabel.isHidden = true
        selectFactPackButton.isHidden = true
        appearanceButton.isHidden = true
        likedFactsButton.isHidden = true
        dislikedFactsButton.isHidden = true
        notSignedInLabel.isHidden = false
    }
    
    private var isLoadingProfileData = false
    
    private func loadUserData() {
        guard let profile = firebaseManager.userProfile else { return }
        
        // Prevent duplicate loading calls
        guard !isLoadingProfileData else {
            print("⚠️ Profile data loading already in progress, skipping")
            return
        }
        
        isLoadingProfileData = true
        
                        emailLabel.text = "👤 \(profile.username) (\(profile.email))"
                cornerTapsLabel.text = "🎯 Corners: \(profile.cornerButtonTaps)"
                
                // Update active fact pack label
                self.updateActiveFactPackLabel()
        

        
        // Load all facts from all fact packs for profile view
        firebaseManager.loadAllFactsForProfile { [weak self] allFacts in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoadingProfileData = false
                
                // Load liked and disliked facts from all fact packs
                self.likedFacts = allFacts.filter { profile.likedFacts.contains($0.id) }
                self.dislikedFacts = allFacts.filter { profile.dislikedFacts.contains($0.id) }
                
                // Update button titles with counts
                self.likedFactsButton.setTitle("❤️ Liked Facts (\(self.likedFacts.count))", for: .normal)
                self.dislikedFactsButton.setTitle("👎 Disliked Facts (\(self.dislikedFacts.count))", for: .normal)
                
                // Log success
                print("✅ Profile loaded successfully with \(allFacts.count) total facts")
            }
        }
    }
    
  
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
    

    
    @objc private func likedFactsButtonTapped() {
        let likedFactsVC = LikedFactsViewController()
        navigationController?.pushViewController(likedFactsVC, animated: true)
    }
    
    @objc private func dislikedFactsButtonTapped() {
        let dislikedFactsVC = DislikedFactsViewController()
        navigationController?.pushViewController(dislikedFactsVC, animated: true)
    }
    
    @objc private func selectFactPackButtonTapped() {
        let factPackSelectionVC = FactPackSelectionViewController()
        navigationController?.pushViewController(factPackSelectionVC, animated: true)
    }
    
    @objc private func appearanceButtonTapped() {
        let currentStyle = traitCollection.userInterfaceStyle
        let newStyle: UIUserInterfaceStyle = currentStyle == .dark ? .light : .dark
        
        // Update the window's user interface style
        if let window = view.window {
            window.overrideUserInterfaceStyle = newStyle
        }
        
        // Update button appearance
        updateAppearanceButton()
        
        // Show feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
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
    
    private func updateActiveFactPackLabel() {
        let factPackManager = FactPackManager.shared
        let currentFactPack = factPackManager.getCurrentFactPackName()
        let packInfo = factPackManager.getFactPackInfo(currentFactPack)
        activeFactPackLabel.text = "📚 Active Fact Pack: \(packInfo.name)"
    }
    
    private func updateAppearanceButton() {
        let currentStyle = traitCollection.userInterfaceStyle
        let isDark = currentStyle == .dark
        
        if isDark {
            appearanceButton.setTitle("☀️ Light Mode", for: .normal)
            appearanceButton.backgroundColor = UIColor.systemYellow
            appearanceButton.setTitleColor(.black, for: .normal)
        } else {
            appearanceButton.setTitle("🌙 Dark Mode", for: .normal)
            appearanceButton.backgroundColor = UIColor.systemIndigo
            appearanceButton.setTitleColor(.white, for: .normal)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update appearance button when system appearance changes
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearanceButton()
        }
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



// MARK: - Custom Table View Cell
class FactTableViewCell: UITableViewCell {
    private let factLabel = UILabel()
    private let factPackLabel = UILabel()
    
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
        
        factPackLabel.numberOfLines = 1
        factPackLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        factPackLabel.textColor = UIColor.systemBlue
        factPackLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        factPackLabel.layer.cornerRadius = 4
        factPackLabel.layer.masksToBounds = true
        factPackLabel.textAlignment = .center
        
        contentView.addSubview(factLabel)
        contentView.addSubview(factPackLabel)
        
        factLabel.translatesAutoresizingMaskIntoConstraints = false
        factPackLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            factLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            factLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            factLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            factPackLabel.topAnchor.constraint(equalTo: factLabel.bottomAnchor, constant: 8),
            factPackLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            factPackLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            factPackLabel.heightAnchor.constraint(equalToConstant: 20),
            factPackLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    func configure(with text: String, factPack: String? = nil, isEmpty: Bool) {
        factLabel.text = text
        factLabel.textColor = isEmpty ? UIColor.secondaryLabel : UIColor.label
        factLabel.font = isEmpty ? UIFont.italicSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        selectionStyle = isEmpty ? .none : .default
        
        if let factPack = factPack, !isEmpty {
            factPackLabel.text = " \(factPack) "
            factPackLabel.isHidden = false
        } else {
            factPackLabel.isHidden = true
        }
    }
}
