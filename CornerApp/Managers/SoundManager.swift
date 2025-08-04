import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()
    private init() {}
    
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Sound Effects
    func playSuccessSound() {
        playSystemSound(.success)
    }
    
    func playErrorSound() {
        playSystemSound(.error)
    }
    
    func playTapSound() {
        playSystemSound(.tap)
    }
    
    // MARK: - System Sounds
    private func playSystemSound(_ soundType: SystemSoundType) {
        switch soundType {
        case .success:
            // Play a success sound using system audio
            AudioServicesPlaySystemSound(1322) // System success sound
        case .error:
            // Play an error sound using system audio
            AudioServicesPlaySystemSound(1323) // System error sound
        case .tap:
            // Play a tap sound using system audio
            AudioServicesPlaySystemSound(1104) // System tap sound
        }
    }
    
    // MARK: - Custom Sound Files (if you want to use custom audio files)
    func playCustomSound(named fileName: String, fileExtension: String = "mp3") {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) else {
            print("❌ Sound file not found: \(fileName).\(fileExtension)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Error playing sound: \(error)")
        }
    }
    
    // MARK: - Haptic Feedback (for additional feedback)
    func playSuccessHaptic() {
        let impactFeedback = UINotificationFeedbackGenerator()
        impactFeedback.notificationOccurred(.success)
    }
    
    func playErrorHaptic() {
        let impactFeedback = UINotificationFeedbackGenerator()
        impactFeedback.notificationOccurred(.error)
    }
    
    func playTapHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - System Sound Types
enum SystemSoundType {
    case success
    case error
    case tap
} 