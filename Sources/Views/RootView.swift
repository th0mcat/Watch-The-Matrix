import SwiftUI
import Matrix

/// A view that displays all of the rooms that the user is currently joined to.
struct RootView: View {
    @Environment(MatrixController.self) private var matrix
    @Environment(VerificationManager.self) private var verificationManager
    
    // sheets and alerts
    @State private var isPresentingSettings = false
    @State private var isPresentingVerification = false
    @State private var syncError: MatrixError?
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Room.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Room.lastMessageDate, ascending: false)],
                  predicate: NSPredicate(format: "isSpace != true"),
                  animation: .default) var rooms: FetchedResults<Room>
    
    var hasEncryptedRooms: Bool {
        rooms.contains(where: \.isEncrypted)
    }
    
    var body: some View {
        List {
            if case let .syncError(error) = matrix.state {
                Button { syncError = error } label: {
                    Text("Sync Error")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            
            ForEach(rooms) { room in
                NavigationLink(value: room) {
                    RoomCell(room: room)
                }
                .disabled(room.isEncrypted && !VerificationManager.isVerified)
            }
        }
        .navigationTitle("Rooms")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { isPresentingSettings = true } label: {
                    Image(systemName: "person")
                }
            }
            
            if hasEncryptedRooms && !VerificationManager.isVerified {
                ToolbarItem(placement: .primaryAction) {
                    Button { isPresentingVerification = true } label: {
                        Image(systemName: "lock.shield")
                    }
                }
            }
        }
        .navigationDestination(for: Room.self) { room in
            RoomView(room: room)
                .environment(matrix)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $isPresentingVerification) {
            VerificationView()
                .environment(matrix)
                .environment(verificationManager)
        }
        .sheet(isPresented: $isPresentingSettings) {
            SettingsView()
        }
        .sheet(item: $syncError) { syncError in
            Text(syncError.description)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static let matrix = MatrixController.preview
    
    static var previews: some View {
        NavigationStack {
            RootView()
                .environment(matrix)
                .environment(VerificationManager())
                .environment(\.managedObjectContext, matrix.dataController.viewContext)
        }
    }
}
