import Foundation

@propertyWrapper
struct Keychain {
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    var wrappedValue: Data? {
        get {
            SecKeyStore.shared.readKey(label: key)
        }
        set {
            if let value = newValue {
                SecKeyStore.shared.storeKey(key: value, label: key)
            } else {
                SecKeyStore.shared.deleteKey(label: key)
            }
        }
    }
}
