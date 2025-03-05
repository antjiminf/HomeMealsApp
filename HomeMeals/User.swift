import Foundation

struct TokenDTO: Codable {
    let token: String
}

struct CreateUser: Codable {
    let name: String
    let username: String
    let password: String
    let email: String
}

struct SIWARequest: Codable {
    let name: String
    let familyName: String
}

struct UserProfile: Codable {
    let id: UUID
    var name: String
    var username: String
    var email: String
    var avatar: String?
}

struct UpdatePassword: Codable {
    let oldPassword: String
    let newPassword: String
}

struct UpdateProfile: Codable {
    let name: String
    let username: String
    let email: String
}
