//
//  RegisterVC.swift
//  fb
//
//  Created by cem bayat on 23.12.2021.
//

import UIKit

 class RegisterVC: UIViewController {

    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtBirthday: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var imgBack: UIImageView!
    var datePicker : UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imgBack.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imgBackTapped))
        imgBack.addGestureRecognizer(gestureRecognizer)
        
        //creating, configuring and implement datePicker into txtBirthday
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(self.datePickerDidChanged(_:)), for: .valueChanged)
        txtBirthday.inputView = datePicker
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        
        // STEP 1. Declaring url of the request; declaring the body to the URL; declaring request with the safest method - POST, that no one can grab our info
        let url = URL(string: "http://192.168.1.34/fb/register.php")!
        let body = "email=\(txtEmail.text!)&firstName=\(txtFirstName.text!)&lastName=\(txtLastName.text!)&password=\(txtPassword.text!)&birthday=\(txtBirthday.text!)&gender=\(txtGender.text!)"
        //print(body)
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        // STEP 2. Execute created above request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let helper = Helper()
            
            if error != nil {
               
                self.performSelector(onMainThread: #selector(self.helperFunc), with: nil, waitUntilDone: false)
                return
            }
            // fetch JSON if no error
            do {
                //save mode of casting data
                guard let data = data else {
                    helper.showAlert(title: "Data Error", message: error!.localizedDescription, vc: self)
                    return
                }

                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                
                guard let parsedJSON = json else {
                    print("Parsing error")
                    return
                }
                
                DispatchQueue.main.async {
                    
                    // successfully logged in
                    if parsedJSON["status"] as! String == "200" {
                        print("DONE")
                        self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                        // saving logged user
                        currentUser = parsedJSON.mutableCopy() as? Dictionary<String, Any>
                        DEFAULTS.set(currentUser, forKey: keyCURRENT_USER)
                        print(parsedJSON)
                        // kayıt olunurken bilgilerde hata varsa
                    } else {
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as? String
                            helper.showAlert(title: "Error", message: message ?? "Error", vc: self)
                        }
                    }
                }
                
                
                
                // error while fetching JSON
            } catch {
                helper.showAlert(title: "JSON Error", message: error.localizedDescription, vc: self)
            }
            
        }.resume()
        
    }
    
    @objc func datePickerDidChanged(_ datePicker : UIDatePicker){
        // declaring the format to be used in TextField while presenting the date
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        txtBirthday.text = formatter.string(from: datePicker.date)
        
        // declaring the format of date, then to place a dummy date into this format
        let compareDateFormatter = DateFormatter()
        compareDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let compareDate = compareDateFormatter.date(from: "2013/01/01 00:01")
        
        // IF logic. If user is older than 5 years, show Continue Button
        if datePicker.date < compareDate! {
            //txtBirthday.isHidden = false
        } else {
            //txtBirthday.isHidden = true
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imgBackTapped(){
        //performSegue(withIdentifier: "toLoginVC", sender: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
     @objc func helperFunc(sender: Error){
        let helper = Helper()
         helper.showAlert(title: "Server error", message: "Server is close ❌", vc: self)
    }
    
  

}
