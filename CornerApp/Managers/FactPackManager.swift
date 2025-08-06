import Foundation
import FirebaseStorage

class FactPackManager: ObservableObject {
    static let shared = FactPackManager()
    private init() {}
    
    @Published var currentFactPack: String = "f1.json"
    @Published var availableFactPacks: [String] = ["f1.json", "f2.json"]
    @Published var isLoading: Bool = false
    
    private let storage = Storage.storage()
    
    // MARK: - Fact Pack Management
    func switchToFactPack(_ factPackName: String, completion: @escaping (Bool) -> Void) {
        guard availableFactPacks.contains(factPackName) else {
            print("❌ Fact pack not available: \(factPackName)")
            completion(false)
            return
        }
        
        isLoading = true
        currentFactPack = factPackName
        
        // Notify FirebaseManager to reload facts with new pack
        FirebaseManager.shared.loadFactsFromFactPack(factPackName) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                completion(success)
            }
        }
    }
    
    func getCurrentFactPackName() -> String {
        return currentFactPack
    }
    
    func getAvailableFactPacks() -> [String] {
        return availableFactPacks
    }
    
    // MARK: - Fact Pack Discovery
    func discoverFactPacks(completion: @escaping ([String]) -> Void) {
        print("🔍 Discovering fact packs from Firebase Storage...")
        
        let storageRef = storage.reference()
        
        // List all files in the root directory
        storageRef.listAll { [weak self] result, error in
            if let error = error {
                print("❌ Error discovering fact packs: \(error)")
                // Fallback to default packs
                let fallbackPacks = ["f1.json", "f2.json"]
                self?.availableFactPacks = fallbackPacks
                completion(fallbackPacks)
                return
            }
            
            guard let result = result else {
                print("❌ No result from Firebase Storage list")
                let fallbackPacks = ["f1.json", "f2.json"]
                self?.availableFactPacks = fallbackPacks
                completion(fallbackPacks)
                return
            }
            
            // Filter for JSON files only
            let jsonFiles = result.items.filter { item in
                item.name.hasSuffix(".json")
            }.map { item in
                item.name
            }
            
            print("📁 Found \(jsonFiles.count) JSON files in Firebase Storage: \(jsonFiles)")
            
            // Validate JSON files and filter out invalid ones
            self?.validateFactPacks(jsonFiles) { validPacks in
                DispatchQueue.main.async {
                    self?.availableFactPacks = validPacks
                    completion(validPacks)
                }
            }
        }
    }
    
    private func validateFactPacks(_ factPacks: [String], completion: @escaping ([String]) -> Void) {
        let group = DispatchGroup()
        var validPacks: [String] = []
        var invalidPacks: [String] = []
        
        for factPack in factPacks {
            group.enter()
            
            let storageRef = storage.reference(withPath: factPack)
            storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                defer { group.leave() }
                
                if let error = error {
                    print("❌ Error validating \(factPack): \(error)")
                    invalidPacks.append(factPack)
                    return
                }
                
                guard let data = data else {
                    print("❌ No data for validation in \(factPack)")
                    invalidPacks.append(factPack)
                    return
                }
                
                do {
                    let _ = try JSONDecoder().decode([Fact].self, from: data)
                    validPacks.append(factPack)
                    print("✅ Validated \(factPack)")
                } catch {
                    print("❌ Invalid JSON in \(factPack): \(error)")
                    invalidPacks.append(factPack)
                }
            }
        }
        
        group.notify(queue: .main) {
            if !invalidPacks.isEmpty {
                print("⚠️ Invalid fact packs found: \(invalidPacks)")
            }
            print("✅ Valid fact packs: \(validPacks)")
            completion(validPacks)
        }
    }
    
    // MARK: - Fact Pack Info
    func getFactPackInfo(_ factPackName: String) -> FactPackInfo {
        // Extract the name from the filename (remove .json extension)
        let packName = factPackName.replacingOccurrences(of: ".json", with: "")
        
        // Convert filename to a readable name
        let displayName = formatFactPackName(packName)
        
        // Generate description based on the name
        let description = generateDescription(for: packName)
        
        // Determine category based on name patterns
        let category = determineCategory(for: packName)
        
        return FactPackInfo(
            name: displayName,
            description: description,
            factCount: 0, // Will be updated when loaded
            category: category
        )
    }
    
    func getFactPackInfoWithCount(_ factPackName: String, completion: @escaping (FactPackInfo) -> Void) {
        var factPackInfo = getFactPackInfo(factPackName)
        
        // Get fact count from Firebase Storage
        let storageRef = storage.reference(withPath: factPackName)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("❌ Error downloading \(factPackName): \(error)")
                factPackInfo.factCount = 0
                DispatchQueue.main.async {
                    completion(factPackInfo)
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received for \(factPackName)")
                factPackInfo.factCount = 0
                DispatchQueue.main.async {
                    completion(factPackInfo)
                }
                return
            }
            
            do {
                let facts = try JSONDecoder().decode([Fact].self, from: data)
                factPackInfo.factCount = facts.count
                print("✅ Successfully decoded \(factPackName): \(facts.count) facts")
            } catch {
                print("❌ Error decoding \(factPackName): \(error)")
                
                // Try to get more details about the JSON error
                if let jsonString = String(data: data, encoding: .utf8) {
                    let firstFewChars = String(jsonString.prefix(100))
                    print("📄 First 100 characters of \(factPackName): \(firstFewChars)")
                }
                
                factPackInfo.factCount = 0
            }
            
            DispatchQueue.main.async {
                completion(factPackInfo)
            }
        }
    }
    
    private func formatFactPackName(_ filename: String) -> String {
        // Simply replace underscores with spaces and keep original case
        return filename
            .replacingOccurrences(of: "_", with: " ")
    }
    
    private func generateDescription(for filename: String) -> String {
        let lowercased = filename.lowercased()
        
        // Generate descriptions based on filename patterns
        if lowercased.contains("science") || lowercased.contains("tech") {
            return "Science and technology facts"
        } else if lowercased.contains("history") {
            return "Historical facts and events"
        } else if lowercased.contains("nature") || lowercased.contains("animals") {
            return "Nature and animal facts"
        } else if lowercased.contains("space") || lowercased.contains("astronomy") {
            return "Space and astronomy facts"
        } else if lowercased.contains("geography") || lowercased.contains("world") {
            return "Geography and world facts"
        } else if lowercased.contains("sports") {
            return "Sports and athletic facts"
        } else if lowercased.contains("food") || lowercased.contains("cooking") {
            return "Food and cooking facts"
        } else if lowercased.contains("music") {
            return "Music and entertainment facts"
        } else if lowercased.contains("test") || lowercased.contains("dev") {
            return "Test fact pack for development"
        } else {
            return "Custom fact collection"
        }
    }
    
    private func determineCategory(for filename: String) -> String {
        let lowercased = filename.lowercased()
        
        if lowercased.contains("science") || lowercased.contains("tech") {
            return "Science"
        } else if lowercased.contains("history") {
            return "History"
        } else if lowercased.contains("nature") || lowercased.contains("animals") {
            return "Nature"
        } else if lowercased.contains("space") || lowercased.contains("astronomy") {
            return "Space"
        } else if lowercased.contains("geography") || lowercased.contains("world") {
            return "Geography"
        } else if lowercased.contains("sports") {
            return "Sports"
        } else if lowercased.contains("food") || lowercased.contains("cooking") {
            return "Food"
        } else if lowercased.contains("music") {
            return "Music"
        } else if lowercased.contains("test") || lowercased.contains("dev") {
            return "Test"
        } else {
            return "General"
        }
    }
}

// MARK: - Fact Pack Info Model
struct FactPackInfo {
    let name: String
    let description: String
    var factCount: Int
    let category: String
} 