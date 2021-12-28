//
//  ViewController.swift
//  fb
//
//  Created by cem bayat on 11.12.2021.
//

import UIKit


var currentUser: Dictionary<String, Any>?
let DEFAULTS = UserDefaults.standard
let keyCURRENT_USER = "currentUser"


class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        loginRequest()
    }
    
    func loginRequest(){
        
            //server a istek gönderme
            let url = URL(string: "http://192.168.1.34/fb/login.php")!
            let body = "email=\(self.txtEmail.text!)&password=\(self.txtPassword.text!)"
            var request = URLRequest(url: url)
            request.httpBody = body.data(using: .utf8)
            request.httpMethod = "POST"
            
            //gelen cevap
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                let helper = Helper()
                // eğer istek göndermede hata olursa, gönderilemezse
                if error != nil {
                    //ana threadde alerti göstermek için
                    self.performSelector(onMainThread: #selector(self.helperFunc), with: nil, waitUntilDone: false)
                    return
                //istek gönderilirse
                } else {
                    //veriyi al
                    do {
                        guard let data = data else {
                            helper.showAlert(title: "Data Error", message: error!.localizedDescription, vc: self)
                            return
                        }
                        //veriyi işle
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                        
                        guard let parsedJSON = json else {
                            print("Parsing error")
                            return
                        }
                        print(parsedJSON)
                        // async olarak alınan veriyi kullan.
                        DispatchQueue.main.async {
                            // successfully logged in
                            if parsedJSON["status"] as! String == "200" {
                                print("giriş yapılıyor")
                                self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                                
                                // saving logged user
                                currentUser = parsedJSON.mutableCopy() as? Dictionary<String, Any>
                                DEFAULTS.set(currentUser, forKey: keyCURRENT_USER)
                                
                                // giriş yapılırken hata olursa : yanlış şifre, kullanıcı bulunamadı...
                            } else {
                                if parsedJSON["message"] != nil {
                                    let message = parsedJSON["message"] as? String
                                    helper.showAlert(title: "Error", message: message ?? "Error", vc: self)
                                }
                            }
                        }
                        // veriyi almada hata olursa.
                    } catch {
                        helper.showAlert(title: "JSON Error", message: error.localizedDescription, vc: self)
                    }
                }
                
            }.resume()
        }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //sunucu kapalıyken. alerti ana threadde göstermek için
    @objc func helperFunc(){
        let helper = Helper()
        helper.showAlert(title: "Server Error", message: "Server is close ❌", vc: self)
    }


}

