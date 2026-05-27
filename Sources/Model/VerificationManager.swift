import Foundation
import Matrix

/// Handles device verification flow state for encrypted Matrix rooms.
@Observable class VerificationManager {
    private static let userDefaultsKey = "deviceVerified"
    
    struct VerificationEmoji: Identifiable {
        let id = UUID()
        let emoji: String
        let description: String
    }
    
    enum VerificationState {
        case unverified
        case requestingVerification
        case showingEmoji([VerificationEmoji])
        case verified
        case failed(Error)
    }
    
    enum VerificationError: LocalizedError {
        case missingCredentials
        
        var errorDescription: String? {
            switch self {
            case .missingCredentials:
                return "Missing user or device details."
            }
        }
    }
    
    var state: VerificationState
    
    var canVerify: Bool {
        if case .unverified = state { return true }
        return false
    }
    
    static var isVerified: Bool {
        UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    init() {
        state = Self.isVerified ? .verified : .unverified
    }
    
    /// Request verification for this watch device.
    func requestVerification(using _: Client, deviceID: String, userID: String) {
        guard !deviceID.isEmpty, !userID.isEmpty else {
            state = .failed(VerificationError.missingCredentials)
            return
        }
        
        state = .requestingVerification
        
        // Matrix SDK note:
        // this project currently does not expose a typed key verification request API here.
        // When `client.requestKeyVerification(for:deviceID:)` (or equivalent to-device request)
        // is available in the SDK, call it from this method.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Placeholder SAS data until Matrix SDK verification callbacks are wired in.
            self.state = .showingEmoji([
                VerificationEmoji(emoji: "🐶", description: "Dog"),
                VerificationEmoji(emoji: "🌙", description: "Moon"),
                VerificationEmoji(emoji: "🚲", description: "Bicycle"),
                VerificationEmoji(emoji: "🌳", description: "Tree"),
                VerificationEmoji(emoji: "📦", description: "Package"),
                VerificationEmoji(emoji: "🎧", description: "Headphones"),
            ])
        }
    }
    
    func confirmVerification() {
        UserDefaults.standard.set(true, forKey: Self.userDefaultsKey)
        state = .verified
    }
    
    func cancelVerification() {
        state = .unverified
    }
}
