import SwiftUI
import AuthenticationServices

extension Notification.Name {
    static let login = Notification.Name("LOGINOK")
}

enum SIWAState {
    case authorized
    case unauthorized
    case notRegistered
}

final class SecManager {
    static let shared = SecManager()
    
    private let AK: [UInt8] = [0xDB-0x68,0x32+0x1A,0x51-0x0A,0x00+0x48,0x4B-0x18,0x5E-0x26,0x40+0x0E,0x76-0x0E,0x34+0x11,0x92-0x48,0x53-0x23,0xAE-0x4F,0x48+0x19,0x13+0x5B,0x97-0x2B,0x5F-0x16,0x83-0x2C,0xB2-0x3B,0x22+0x46,0x98-0x25,0x55+0x25,0x5C-0x2B,0x43-0x16,0x24+0x28,0x60+0x01,0x3E+0x34,0x04+0x3F,0x97-0x2B,0x44+0x01,0x0E+0x61,0xBA-0x52,0x74-0x0B,0x63-0x22,0x7C-0x34,0x35+0x1C,0xAD-0x3C,0x23+0x3E,0x18+0x61,0x37+0x0F,0x05+0x2B,0x70-0x2A,0x8C-0x33]
    
    var apiKey: String {
        String(data: Data(AK), encoding: .utf8) ?? ""
    }
    
    var isJWToken = false
    var siwaState: SIWAState = .notRegistered
    
    init() {
        isJWToken = SecKeyStore.shared.readKey(label: "token") != nil
        let provider = ASAuthorizationAppleIDProvider()
        
        guard let appleIdUserData = SecKeyStore.shared.readKey(label: "APPLEIDUSER"),
              let appleIdUser = String(data: appleIdUserData, encoding: .utf8) else { return }
        
        provider.getCredentialState(forUserID: appleIdUser) { [self] state, error in
            guard error == nil else { return }
            
            switch state {
                case .authorized:
                    siwaState = .authorized
                case .notFound:
                    siwaState = .notRegistered
                default:
                    siwaState = .unauthorized
            }
        }
        
        Task { await testJWT() }
    }
    
    func testJWT() async {
        do {
            try await Network.shared.testJWT()
        } catch {
            logOut()
            isJWToken = false
        }
    }
    
    func isLogged() -> Bool {
        if isJWToken {
            if siwaState == .authorized || siwaState == .notRegistered {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func SIWACredentials(credential: ASAuthorizationCredential) async throws {
        guard let credential = credential as? ASAuthorizationAppleIDCredential,
              let token = credential.identityToken else { return }
        
        let user = Data(credential.user.utf8)
        SecKeyStore.shared.storeKey(key: user, label: "APPLEIDUSER")
        
        let request = SIWARequest(name: credential.fullName?.givenName ?? "",
                                  familyName: credential.fullName?.familyName ?? "")
        try await Network.shared.loginSIWA(token: token, request: request)
    }
    
    func logOut() {
        SecKeyStore.shared.deleteKey(label: "token")
        SecKeyStore.shared.deleteKey(label: "APPLEIDUSER")
    }
}
