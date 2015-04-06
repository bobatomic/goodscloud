import UIKit
import XCTest

class CommunicatorTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testStartGoodsCloudSession(){
   
        let expectation = self.expectationWithDescription("Return JSON")
        let cm:Communicator = Communicator(baseURL: Config.sharedInstance.baseURL())
        cm.startGoodsCloudSession { (response) -> () in
            expectation.fulfill()
            XCTAssertTrue(response.isKindOfClass(NSDictionary))
        }
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
}
