//
//  SettingsVC.swift
//  fb
//
//  Created by cem bayat on 23.12.2021.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var lblEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblEmail.text = currentUser!["email"] as? String
    }
    

    @IBAction func btnLogOutClicked(_ sender: Any) {
        DEFAULTS.removeObject(forKey: keyCURRENT_USER)
        performSegue(withIdentifier: "toLoginVC", sender: nil)
    }
    

}
