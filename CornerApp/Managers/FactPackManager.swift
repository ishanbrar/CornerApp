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
        // For now, we'll use a predefined list
        // In the future, you could scan Firebase Storage for available fact packs
        let discoveredPacks = ["f1.json", "f2.json"]
        availableFactPacks = discoveredPacks
        completion(discoveredPacks)
    }
    
    // MARK: - Fact Pack Info
    func getFactPackInfo(_ factPackName: String) -> FactPackInfo {
        switch factPackName {
        case "f1.json":
            return FactPackInfo(
                name: "Main Facts",
                description: "Primary fact collection with diverse topics",
                factCount: 0, // Will be updated when loaded
                category: "General"
            )
        case "f2.json":
            return FactPackInfo(
                name: "Test Facts",
                description: "Test fact pack for development",
                factCount: 0, // Will be updated when loaded
                category: "Test"
            )
        default:
            return FactPackInfo(
                name: factPackName,
                description: "Custom fact pack",
                factCount: 0,
                category: "Custom"
            )
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