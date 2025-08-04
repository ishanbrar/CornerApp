//
//  FirebaseManager.swift
//  CornerApp
//
//  Created by Jar Jar on 8/2/25.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseStorage

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var facts: [Fact] = []
    
    private init() {
        setupAuthListener()
        //loadSampleFacts()
        loadFactsFromFirebaseStorage()
        
    }
    
    private func setupAuthListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            if let user = user {
                self?.loadUserProfile(uid: user.uid)
            } else {
                self?.userProfile = nil
            }
        }
    }
    private func loadFactsFromFirebaseStorage() {
        loadFactsFromFactPack("f1.json") { _ in }
    }
    
    func loadFactsFromFactPack(_ factPackName: String, completion: @escaping (Bool) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: factPackName)
        
        print("🔄 Loading facts from fact pack: \(factPackName)")
        
        storageRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
            if let error = error {
                print("❌ Failed to download facts JSON from \(factPackName): \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("❌ No data received from Firebase Storage for \(factPackName).")
                completion(false)
                return
            }
            
            do {
                let facts = try JSONDecoder().decode([Fact].self, from: data)
                DispatchQueue.main.async {
                    self?.facts = facts
                    print("✅ Loaded \(facts.count) facts from fact pack: \(factPackName)")
                    
                    // Debug: Print first few fact IDs to verify they're correct
                    for (index, fact) in facts.prefix(5).enumerated() {
                        print("📋 Fact \(index + 1): ID=\(fact.id), Text=\(fact.text.prefix(50))...")
                    }
                    
                    completion(true)
                }
            } catch {
                print("❌ Failed to decode facts JSON from \(factPackName): \(error)")
                completion(false)
            }
        }
    }
    
    private func loadSampleFacts() {
        // Sample facts - you can replace this with loading from Firebase Storage
        facts = [
            Fact(text: "Octopuses have three hearts and blue blood. Two hearts pump blood to the gills, while the third pumps blood to the rest of the body.", category: "Science"),
            Fact(text: "The longest place name in the world is 85 letters long: Taumatawhakatangihangakoauauotamateaturipukakapikimaungahoronukupokaiwhenuakitanatahu, a hill in New Zealand.", category: "Geography"),
            Fact(text: "Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly edible.", category: "History"),
            Fact(text: "A group of flamingos is called a 'flamboyance.' They get their pink color from eating shrimp and algae rich in carotenoids.", category: "Animals"),
            Fact(text: "The human brain uses about 20% of the body's total energy, despite only making up about 2% of body weight.", category: "Science")
        ]
    }
    
    // MARK: - Authentication
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            // Create user profile in Firestore
            let profile = UserProfile(uid: user.uid, email: email, username: username)
            self?.saveUserProfile(profile) { result in
                switch result {
                case .success:
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("🔥 FirebaseManager: Starting sign in for \(email)")
        
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ FirebaseManager: Sign in failed - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                print("❌ FirebaseManager: No user returned from sign in")
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in"])))
                return
            }
            
            print("✅ FirebaseManager: Sign in successful for \(user.email ?? "unknown")")
            completion(.success(user))
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - User Profile Management
    // MARK: - User Profile Management
    private func loadUserProfile(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error loading user profile: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                // Create new profile if doesn't exist
                let profile = UserProfile(uid: uid, email: self?.currentUser?.email ?? "", username: "User\(Int.random(in: 1000...9999))")
                self?.saveUserProfile(profile) { _ in }
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let profile = try JSONDecoder().decode(UserProfile.self, from: jsonData)
                DispatchQueue.main.async {
                    self?.userProfile = profile
                }
            } catch {
                print("Error decoding user profile: \(error)")
                // If decoding fails, it might be an old profile without username
                // Create a new profile with username
                let profile = UserProfile(uid: uid, email: self?.currentUser?.email ?? "", username: "User\(Int.random(in: 1000...9999))")
                self?.saveUserProfile(profile) { _ in }
            }
        }
    }
    
    private func saveUserProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(profile)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            db.collection("users").document(profile.uid).setData(dict) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self.userProfile = profile
                    }
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Fact Interactions
    func incrementCornerTaps() {
        guard var profile = userProfile else { return }
        profile.cornerButtonTaps += 1
        saveUserProfile(profile) { _ in }
    }
    
    func likeFact(_ factId: String, completion: (() -> Void)? = nil) {
        guard var profile = userProfile else { return }
        if !profile.likedFacts.contains(factId) {
            profile.likedFacts.append(factId)
            profile.dislikedFacts.removeAll { $0 == factId }
            saveUserProfile(profile) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    
    func dislikeFact(_ factId: String, completion: (() -> Void)? = nil) {
        guard var profile = userProfile else { return }
        if !profile.dislikedFacts.contains(factId) {
            profile.dislikedFacts.append(factId)
            profile.likedFacts.removeAll { $0 == factId }
            saveUserProfile(profile) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
        
        func getRandomFact() -> Fact? {
            let fact = facts.randomElement()
            if let fact = fact {
                print("🎲 Selected random fact: ID=\(fact.id), Text=\(fact.text.prefix(50))...")
            } else {
                print("❌ No facts available for random selection")
            }
            return fact
        }
    }

