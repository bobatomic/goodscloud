import Foundation

class Config: NSObject {
    
    let configPlist:NSDictionary?
   
    override init() {
        self.configPlist = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!)
    }
    
    class var sharedInstance: Config {
    
        struct shared {
            static var __sharedInstance:Config?
            static var __dispatchToken:dispatch_once_t = 0
        }
        
        dispatch_once(&shared.__dispatchToken) {
            shared.__sharedInstance = Config()
        }
        
        return shared.__sharedInstance!
    }
    
    func baseURL() -> NSURL {
        return NSURL(string: self.configPlist!["WebServiceBaseURL"] as! String)!
    }
    
    func goodsCloudEmail () -> String {
        return self.configPlist!["GC-Email"] as! String!
    }
    
    func goodsCloudPassword () -> String {
        return self.configPlist!["GC-Password"] as! String
    }
    
}