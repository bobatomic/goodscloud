import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let cm:Communicator = Communicator(baseURL: Config.sharedInstance.baseURL())
        cm.startGoodsCloudSession { (response) -> () in
            println("\(response)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

