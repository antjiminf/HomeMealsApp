import Foundation
import CryptoKit

/**
 A class that provides encryption and decryption functionalities using AES-GCM.
 
 `Krypto` is a singleton class that handles symmetric key encryption and decryption.
 It generates and stores a random key in the Keychain for secure data handling.
 
 Usage:
 ```swift
 let encryptedData = try? Krypto.shared.GCMEncrypt(value: "Sensitive Data")
 let decryptedData = try? Krypto.shared.GCMDecrypt(data: encryptedData)
 ```
 - Note: This class uses CryptoKit for cryptographic operations.
 */
final class Krypto {
    static let shared = Krypto()
    
    let key: SymmetricKey
    var randomKey: Data
    
    var keyData: Data {
        Data(key.withUnsafeBytes({ Array($0) }))
    }
    
    init() {
        if let data = SecKeyStore.shared.readKey(label: "cryptoKey") {
            self.key = SymmetricKey(data: data)
        } else {
            self.key = SymmetricKey(size: .bits256)
            let keyData = Data(key.withUnsafeBytes({ Array($0) }))
            SecKeyStore.shared.storeKey(key: keyData, label: "cryptoKey")
        }
        if let data = SecKeyStore.shared.readKey(label: "secRandom") {
            self.randomKey = data
        } else {
            var digest = [UInt8](repeating: 0, count: 32)
            let result = SecRandomCopyBytes(kSecRandomDefault, 32, &digest)
            if result == errSecSuccess {
                self.randomKey = Data(digest)
                SecKeyStore.shared.storeKey(key: self.randomKey, label: "secRandom")
            } else {
                self.randomKey = Data()
                print("No se ha grabado una clave random para el keychain.")
            }
        }
    }
    
    /**
     Encrypts a given string using AES-GCM.
     
     - Parameter value: The string to be encrypted.
     - Returns: The encrypted data.
     - Throws: An error if the encryption fails.
     */
    func GCMEncrypt(value: String) throws -> Data? {
        let data = Data(value.utf8)
        let box = try AES.GCM.seal(data, using: key)
        return box.combined
    }
    
    func GCMDecrypt(data: Data) throws -> String? {
        let box = try AES.GCM.SealedBox(combined: data)
        let open = try AES.GCM.open(box, using: key)
        return String(data: open, encoding: .utf8)
    }
    
    func ChachaEncrypt(value: String) throws -> Data {
        let data = Data(value.utf8)
        let box = try ChaChaPoly.seal(data, using: key)
        return box.combined
    }
    
    func ChachaDecrypt(data: Data) throws -> String? {
        let box = try ChaChaPoly.SealedBox(combined: data)
        let open = try ChaChaPoly.open(box, using: key)
        return String(data: open, encoding: .utf8)
    }
    
    func ChachaJSONEncrypt<JSON>(json: JSON) throws -> Data where JSON: Encodable {
        let data = try JSONEncoder().encode(json)
        let box = try ChaChaPoly.seal(data, using: key)
        return box.combined
    }
    
    func ChachaJSONDecrypt<JSON>(data: Data, type: JSON.Type) throws -> JSON where JSON: Decodable {
        let box = try ChaChaPoly.SealedBox(combined: data)
        let open = try ChaChaPoly.open(box, using: key)
        return try JSONDecoder().decode(type, from: open)
    }
}
