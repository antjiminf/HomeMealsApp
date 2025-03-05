import SwiftUI

@Observable
final class UserVM {
    private let interactor: DataInteractor
    
    var userProfile: UserProfile?
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
    }
    
    /// 🔄 Carga el perfil del usuario desde la API
    func loadUserProfile() async {
        do {
            self.userProfile = try await interactor.getUserProfile()
        } catch {
            print("❌ Error loading user profile: \(error.localizedDescription)")
        }
    }
    
    /// 🔄 Refresca manualmente el perfil
    func refreshProfile() {
        Task {
            await loadUserProfile()
        }
    }
    
    /// 🔐 Cierra sesión y borra los datos del usuario
    func logOut() {
        SecManager.shared.logOut()
        userProfile = nil
    }
}
