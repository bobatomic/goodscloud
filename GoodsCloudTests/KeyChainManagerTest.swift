import UIKit
import XCTest

class KeychainTests: XCTestCase {
    
    override func setUp() {
        KeychainManager.clearKey()
        super.setUp()
    }
    
    override func tearDown() {
        KeychainManager.clearKey()
        super.tearDown()
    }
    
    func testAddKey() {
        
        let storeKey = "andreas.stein@goodscloud.comxx"
        let storedData = "YW5kcmVhcy5zdGVpbkBnb29kc2Nsb3VkLmNvbToxMjM0NTY3OA".dataValue
        
        XCTAssertTrue(KeychainManager.loadKey(storeKey) == nil)
        XCTAssertTrue(KeychainManager.addKey(storeKey, data: storedData))
        XCTAssertTrue(KeychainManager.loadKey(storeKey) != nil)
    }
    
    
    func testDeleteKey() {
        let firstKey = "andreas.stein@goodscloud.comxx"
        let secondKey = "andreas.stein@goodscloud.comyy"
        let storedData = "YW5kcmVhcy5zdGVpbkBnb29kc2Nsb3VkLmNvbToxMjM0NTY3OA".dataValue
        
        XCTAssertTrue(KeychainManager.addKey(firstKey, data: storedData))
        XCTAssertTrue(KeychainManager.addKey(secondKey, data: storedData))
        
        XCTAssertTrue(KeychainManager.loadKey(firstKey) != nil)
        XCTAssertTrue(KeychainManager.loadKey(secondKey) != nil)
        
        XCTAssertTrue(KeychainManager.deleteKey(firstKey))
        
        XCTAssertTrue(KeychainManager.loadKey(firstKey) == nil)
        XCTAssertTrue(KeychainManager.loadKey(secondKey) != nil)
    }
    
    func testLoadKey(){
        let storeKey = "andreas.stein@goodscloud.comxx"
        let storedData = "YW5kcmVhcy5zdGVpbkBnb29kc2Nsb3VkLmNvbToxMjM0NTY3OA".dataValue
        
        KeychainManager.addKey(storeKey, data: storedData)
        XCTAssertTrue(KeychainManager.loadKey(storeKey) != nil)

        let loadedData = KeychainManager.loadKey(storeKey)!
        
        XCTAssertEqual(loadedData.stringValue, storedData.stringValue)
    }
    
}