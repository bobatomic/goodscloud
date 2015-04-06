import Foundation
import Security

class KeychainManager {
    
    class func addKey(key: String, data: NSData) -> Bool {
        let query = [
            kSecClass as! String       : kSecClassGenericPassword as! String,
            kSecAttrAccount as! String : key,
            kSecValueData as! String   : data ]
        
        SecItemDelete(query as CFDictionaryRef)
        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)
        
        return status == noErr
    }
    
    class func loadKey(key: String) -> NSData? {
        let query = [
            kSecClass as! String       : kSecClassGenericPassword,
            kSecAttrAccount as! String : key,
            kSecReturnData as! String  : kCFBooleanTrue,
            kSecMatchLimit as! String  : kSecMatchLimitOne ]
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == noErr {
            return (dataTypeRef!.takeRetainedValue() as! NSData)
        } else {
            return nil
        }
    }
    
    class func deleteKey(key: String) -> Bool {
        let query = [
            kSecClass as! String       : kSecClassGenericPassword,
            kSecAttrAccount as! String : key ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
    class func clearKey() -> Bool {
        let query = [ kSecClass as String : kSecClassGenericPassword ]
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
}