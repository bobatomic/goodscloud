import Foundation

class Communicator: NSObject {
    
    private struct URLPaths {
        static var session = "/session"
        static var companyProduct = "/api/internal/company_product"
        static var consumers = "api/internal/consumers"
    }
    
    private struct HTTPMethods {
        static var HTTPMethodPOST = "POST"
        static var HTTPMethodGET = "GET"
        static var HTTPMethodPUT = "PUT"
        static var HTTPMetodDELETE = "DELETE"
    }
    
    private struct AuthToken {
        
        static var authenticationName = "api.goodsCloud.app"
        static var authenticationParam = "auth"
        static var authenticationEmail = "email"
        static var authenticationError = "Authentication Error"
    }
    
    var isActiveSession:Bool!
    let URLSession:NSURLSession!
    let baseURL:NSURL!

    init(baseURL:NSURL) {
        self.baseURL = baseURL
        self.URLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil)
        self.isActiveSession = false
    }
   
     func base64DataAuthenticationStringForUsername(username:String!, password:String!) -> (String, NSData) {
        
        let loginString = "\(username):\(password)"
        let loginData = (loginString as String).dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = loginData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return ("Basic \(base64String)", loginData!)
    }
    
    func stringFromParameters(parameters : Dictionary<String, String>) -> String {
        
        var arrayOfStrings: [String] = []
        for (key, value) in parameters {
            var parameter = "\(key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)=\(value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)"
            arrayOfStrings.append(parameter)
        }
        return "&".join(arrayOfStrings)
    }
    
    func URLForQueryWithPath(path: String?, parameters:Dictionary<String, String>?) -> NSURL {
        
        var pathWithParameters:String?
        
        if path != nil && parameters != nil {
            pathWithParameters = "\(path!)?\(self.stringFromParameters(parameters!))"
        }else if path != nil && parameters == nil {
            pathWithParameters = "\(path!)?"
        }else if path == nil && parameters != nil {
            pathWithParameters = "?\(self.stringFromParameters(parameters!))"
        }else{
            pathWithParameters = "?"
        }
        
        return NSURL(string: pathWithParameters!, relativeToURL: self.baseURL)!
    }
    
    func performWebServiceCallWithURL(URL: NSURL, method:String, parameters:Dictionary<String, String>, success: (response: NSDictionary)->(), failure: (error: CommunicatorError?)->()) {

        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = method
        //let base64StringData = base64DataAuthenticationStringForUsername(Config.sharedInstance.goodsCloudEmail(), password: Config.sharedInstance.goodsCloudPassword())
        //request.addValue(base64StringData.0, forHTTPHeaderField: "Authorization")
        //KeychainManager.addKey(AuthToken.authenticationName, data: base64StringData.1)
        
        if URL.path != URLPaths.session {
            var authData = KeychainManager.loadKey(AuthToken.authenticationName)
            //var authString: NSString = NSString(data:authData!, encoding:NSUTF8StringEncoding)!//added extension to String
            //request.addValue(authString as String, forHTTPHeaderField: AuthToken.authenticationParam)
            request.addValue(authData?.stringValue, forHTTPHeaderField: AuthToken.authenticationParam)
        }
        
        let task = self.URLSession.dataTaskWithRequest(request, completionHandler: { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
            if error != nil {
                return failure(error: CommunicatorError.CommunicatorNetworkError)
            } else {
                let HTTPStatusCode = (response as! NSHTTPURLResponse).statusCode
                
                if HTTPStatusCode == 200 {
                    var serializationError: NSError?
                    var JSONResponse: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &serializationError) as! NSDictionary
                    
                    if serializationError != nil {
                        return failure(error: CommunicatorError.CommunicatorJSONSerializationError(errorMessage: serializationError!.localizedDescription))
                    } else {
                        return success(response: JSONResponse)
                    }
                } else {
                    return failure(error: CommunicatorError.CommunicatorServerError(errorMessage: HTTPStatusCode.description))
                }
                
            }
        })
        task.resume()
    }
    
    enum CommunicatorError: Printable {
        
        case CommunicatorNetworkError
        case CommunicatorHTTPStatusError(statusCode: Int)
        case CommunicatorServerError(errorMessage: String)
        case CommunicatorJSONSerializationError(errorMessage: String)
        case CommunicatorAuthenticationError(errorMeassage: String)
        case CommunicatorActiveSessionError(errorMeassage: String)
        
        var description: String {
            
            switch self
            {
            case .CommunicatorNetworkError:
                return "Network or internet connection unavailable"
            case .CommunicatorHTTPStatusError(let statusCode):
                return "Request failed with HTTPStatusCode \(statusCode)"
            case .CommunicatorServerError(let errorMessage):
                return "The server responded with message \(errorMessage)"
            case .CommunicatorJSONSerializationError(let errorMessage):
                return "Invalid JSONResponse \(errorMessage)"
            case .CommunicatorAuthenticationError(let errorMeassage):
                return "Invalid Username or password \(errorMeassage)"
            case .CommunicatorActiveSessionError(let errorMeassage):
                return "Please start session first \(errorMeassage)"
            }
        }
    }
    
    func startGoodsCloudSession (completion:(response: NSDictionary)->()) -> ()  {
        
        var parameters = Dictionary<String, String>()
        parameters["GC-Email"] = Config.sharedInstance.goodsCloudEmail()
        parameters["GC-Password"] = Config.sharedInstance.goodsCloudPassword()
        parameters["GC-AWS"] = "true"
        
        let URL = self.URLForQueryWithPath(URLPaths.session, parameters: parameters)
        
        self.performWebServiceCallWithURL(URL, method: HTTPMethods.HTTPMethodPOST, parameters: parameters, success: { (response) -> () in
            
            if let email:String = response[AuthToken.authenticationEmail] as? String {
            
                let email:String = response[AuthToken.authenticationEmail] as! String
                let auth:String = response[AuthToken.authenticationParam] as! String
                //let authData = (auth as String).dataUsingEncoding(NSUTF8StringEncoding)//added extension NSData
                KeychainManager.addKey(AuthToken.authenticationName, data: auth.dataValue)
                
                self.isActiveSession = true
                completion(response: response)
                
            } else {
               let error = CommunicatorError.CommunicatorAuthenticationError(errorMeassage: AuthToken.authenticationError)
                println("\(error)")
                self.isActiveSession = false
                
                completion(response: response)
            }

        }) { (error) -> () in
            println("\(error)")
            self.isActiveSession = false
        }
    }
    
    func activeSession ()-> Bool {
        return isActiveSession!
    }
    
    func fetchCompantyProductWithParameter (parameters:Dictionary<String, String>, success:(response: NSDictionary)->(), failure:(error: CommunicatorError?)->(), completion:()->()){
        
        let URL = self.URLForQueryWithPath(URLPaths.session, parameters: parameters)
        
        if activeSession(){
            self.performWebServiceCallWithURL(URL, method: HTTPMethods.HTTPMethodPOST, parameters: parameters, success: { (response) -> () in
                //FIXME Return resposnse to manager for model bulding
            }, failure: { (error) -> () in
                //FIXME: Return error to manager
                println("\(errno)")
            })
        }
    }
}

extension String {
    public var dataValue: NSData {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
}

extension NSData {
    public var stringValue: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding)! as String
    }
}
