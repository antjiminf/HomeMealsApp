import SwiftUI

@Observable
final class UserVM {
    private let interactor: DataInteractor
    
    var userProfile: UserProfile?
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
        if SecManager.shared.isLogged() {
            Task { await loadUserProfile() }
        }
        NotificationCenter.default.addObserver(forName: .login, object: nil, queue: .main) { _ in
            Task { await self.loadUserProfile() }
        }
    }
    
    func loadUserProfile() async {
        do {
            self.userProfile = try await interactor.getUserProfile()
        } catch {
            print("Error loading user profile: \(error.localizedDescription)")
        }
    }
    
    func refreshProfile() {
        Task {
            await loadUserProfile()
        }
    }
    
    func logOut() {
        SecManager.shared.logOut()
        userProfile = nil
    }
    
    func updatePassword(_ request: UpdatePassword) async throws {
        try await interactor.updatePassword(request)
    }
    
    func updateProfile(_ updatedProfile: UpdateProfile) async throws {
        
        try await interactor.updateProfile(updatedProfile)
        userProfile?.email = updatedProfile.email
        userProfile?.name = updatedProfile.name
        userProfile?.username = updatedProfile.username
    }
}
