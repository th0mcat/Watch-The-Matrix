import SwiftUI
import Matrix

struct VerificationView: View {
    @Environment(MatrixController.self) private var matrix
    @Environment(VerificationManager.self) private var verificationManager
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Verify Device")
                    .font(.headline)
                
                Text("Verify this Apple Watch from another Matrix client to access encrypted rooms.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                switch verificationManager.state {
                case .unverified:
                    Button("Request Verification", action: requestVerification)
                        .disabled(!verificationManager.canVerify)
                case .requestingVerification:
                    ProgressView("Waiting for verification…")
                case .showingEmoji(let emojis):
                    LazyVGrid(columns: columns) {
                        ForEach(emojis) { emoji in
                            VStack(spacing: 4) {
                                Text(emoji.emoji)
                                    .font(.title2)
                                Text(emoji.description)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        }
                    }
                    
                    HStack {
                        Button("Confirm") {
                            verificationManager.confirmVerification()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Cancel") {
                            verificationManager.cancelVerification()
                        }
                        .buttonStyle(.bordered)
                    }
                case .verified:
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.title)
                        Text("Device Verified")
                            .font(.headline)
                        Button("Done") { dismiss() }
                    }
                case .failed(let error):
                    VStack(spacing: 8) {
                        Text("Verification Failed")
                            .foregroundColor(.red)
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") { verificationManager.cancelVerification() }
                    }
                }
            }
            .padding()
        }
    }
    
    private func requestVerification() {
        guard let deviceID = matrix.deviceID, let userID = matrix.userID else {
            verificationManager.state = .failed(VerificationManager.VerificationError.missingCredentials)
            return
        }
        
        verificationManager.requestVerification(using: matrix.client, deviceID: deviceID, userID: userID)
    }
}

struct VerificationView_Previews: PreviewProvider {
    static let matrix = MatrixController.preview
    
    static var previews: some View {
        VerificationView()
            .environment(matrix)
            .environment(VerificationManager())
    }
}
