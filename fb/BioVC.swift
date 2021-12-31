//
//  BioVC.swift
//  fb
//
//  Created by cem bayat on 30.12.2021.
//

import UIKit

class BioVC: UIViewController{

    @IBOutlet weak var imgAva: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var remainingChars = 1
    var txtBio : String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadUser()
        configure_imgAva()
        configure_btn()
    }
    
 
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        uploadBio()
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func loadUser(){
        
        guard let firstName = currentUser?["firstName"],
              let lastName = currentUser?["lastName"],
              let ava = currentUser?["ava"]
        else{
            return
        }
        
        lblFullName.text = "\((firstName as? String)!.capitalized) \((lastName as? String)!.capitalized)"
        Helper().downloadImage(from: ava as! String, showIn: imgAva, orShow: "user.jpg")
    }
    

    
    func configure_imgAva(){
        imgAva.layer.cornerRadius = imgAva.frame.width / 2
        imgAva.clipsToBounds = true
    }
    
    func configure_btn(){
        btnSave.layer.cornerRadius = 10
        btnCancel.layer.cornerRadius = 10
    }
    
    
    func uploadBio(){
        
        guard let id = currentUser?["id"] else {return}
        
        let url = URL(string: "http://\(Ip().ip)/fb/updateBio.php")!
        let body = "id=\(id)&bio=\(txtBio)"
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    Helper().showAlert(title: "Error", message: error!.localizedDescription, vc: self)
                    return
                } else if data != nil {
                    
                    do {
                        guard let data = data else {
                            Helper().showAlert(title: "Data Error", message: error!.localizedDescription, vc: self)
                            return
                        }
                        
                        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        
                        guard let parsedJSON = json else {
                            Helper().showAlert(title: "Parsing Error", message: error!.localizedDescription, vc: self)
                            return
                        }
                        
                        if parsedJSON["status"] as! String == "200" {
                            
                            
                            
                            currentUser = parsedJSON.mutableCopy() as? Dictionary<String, Any>
                            DEFAULTS.set(currentUser, forKey: keyCURRENT_USER)
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBio"), object: nil)
                            
                            print(parsedJSON)
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        

                        
                        
                    } catch {
                        Helper().showAlert(title: "JSON Error", message: error.localizedDescription, vc: self)
                    }
                    
                }
                
                
                
            }
        }.resume()
    }
    

}

extension BioVC : UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            lblPlaceholder.isHidden = false
        } else {
            lblPlaceholder.isHidden = true
        }
        
        checkRemainingChars()
        
        lblCounter.text = "\(remainingChars)/101"
        
        txtBio = textView.text
    }
    
    
    
    func checkRemainingChars(){
        
        let allowedChars = 101
        let charsInTextView = -textView.text.count
        remainingChars = allowedChars + charsInTextView
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            return false
        }
        
        return textView.text.count + (text.count - range.length) <= 101
    }
    
}
