//
//  EditVC.swift
//  fb
//
//  Created by cem bayat on 9.01.2022.
//

import UIKit

class EditVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgAva: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var btnAddBio: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtBirthday: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    
    var imageViewTapped = ""
    var isCover = false
    var isAva = false
    var isCoverChanged = false
    var isAvaChanged = false
    var isPasswordChanged = false
    
    var datePicker : UIDatePicker!
    var genderPicker : UIPickerView!
    let genderPickerValues = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure_imgAva()
        loadUser()
        
        imgCover.isUserInteractionEnabled = true
        imgAva.isUserInteractionEnabled = true
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(imgCoverTapped))
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imgAvaTapped))
        imgCover.addGestureRecognizer(gestureRecognizer1)
        imgAva.addGestureRecognizer(gestureRecognizer2)
        
        //creating, configuring and implement datePicker into txtBirthday
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(self.datePickerDidChanged(_:)), for: .valueChanged)
        txtBirthday.inputView = datePicker
        
        // create and configure gender picker view for genderTextField
        genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        txtGender.inputView = genderPicker
        
    }
    
    
    @IBAction func btnSave_clicked(_ sender: Any) {
        updateUser()
        
        if isAvaChanged == true {
            uploadImage(from: imgAva, type: "ava") {
                Helper().showAlert(title: "Success!", message: "Ava has been updated", vc: self)
            }
        }
        
        if isCoverChanged == true {
            uploadImage(from: imgCover, type: "cover") {
                Helper().showAlert(title: "Success!", message: "Cover has been updated", vc: self)
            }
        }
        
        if isAvaChanged == true && isCoverChanged == true {
            
            uploadImage(from: imgAva, type: "ava") {
                self.uploadImage(from: self.imgCover, type: "cover") {
                    Helper().showAlert(title: "Success!", message: "Cover and Ava have been updated", vc: self)
                }
            }
            
        }
        
        // sending notification to other vcs
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUser"), object: nil)
        
    }
    
    
    func updateUser(){
        guard let id = currentUser?["id"] else {
            return
        }
        
        let email = txtEmail.text!
        let firstName = txtFirstName.text!
        let lastName = txtLastName.text!
        let birthday = datePicker.date
        let password = txtPassword.text!
        let gender = txtGender.text!
        
        // prepare request
        let url = URL(string: "http://\(Ip().ip)/fb/updateUser.php")!
        let body = "id=\(id)&email=\(email)&firstName=\(firstName)&lastName=\(lastName)&birthday=\(birthday)&gender=\(gender)&newPassword=\(isPasswordChanged)&password=\(password)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error?.localizedDescription ?? "server error", vc: self)
                    return
                }
                
                print(body)
                
                do {
                    
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error?.localizedDescription ?? "data error", vc: self)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    guard let parsedJSON = json else {
                        Helper().showAlert(title: "Parsing Error", message: error?.localizedDescription ?? "parsing error", vc: self)
                        return
                    }
                    
                    if parsedJSON["status"] as! String == "200" {
                        
                        currentUser = parsedJSON.mutableCopy() as? Dictionary<String, Any>
                        DEFAULTS.set(currentUser, forKey: keyCURRENT_USER)
                    
                        Helper().showAlert(title: "Success!", message: "User is updated successfully", vc: self)
                        
                        print(currentUser!)
                        
                        // sending notification to other vcs
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUser"), object: nil)
                        
                    } else {
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            Helper().showAlert(title: "", message: message, vc: self)
                        }
                        
                    }

                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, vc: self)
                    return
                }
            }
            
        }.resume()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func loadUser(){
        // safe method of accessing user related information in glob var
        guard let firstName = currentUser?["firstName"],
            let lastName = currentUser?["lastName"],
            let email = currentUser?["email"],
            let birthday = currentUser?["birthday"] as? String,
            let gender = currentUser?["gender"],
            let avaPath = currentUser?["ava"],
            let coverPath = currentUser?["cover"] else {
            return
        }
        
        txtFirstName.text = (firstName as! String).capitalized
        txtLastName.text = (lastName as! String).capitalized
        txtEmail.text = "\(email)"
        txtBirthday.text = "\(birthday)"
        txtGender.text = "\(gender)"
        
        // STEP 1 - To Show the Date in the UI format: To place string of date in the valid date format to convert to the Date Type
        let formatterGet = DateFormatter()
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss 0000"
        let date = formatterGet.date(from: birthday)!
        
        // STEP 2 -To Show the Date in the UI format: To declare a new format of showing the date to the users
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMM dd, yyyy"
        txtBirthday.text = formatterShow.string(from: date)
        
        Helper().downloadImage(from: coverPath as! String, showIn: self.imgCover, orShow: "HomeCover.jpg")
        Helper().downloadImage(from: avaPath as! String, showIn: self.imgAva, orShow: "user.jpg")
        
        if (avaPath as! String).count > 10 {
            isAva = true
        } else {
            imgAva.image = UIImage(named: "user.png")
            isAva = false
        }
        
        if (coverPath as! String).count > 10 {
            isCover = true
        } else {
            imgCover.image = UIImage(named: "HomeCover.jpg")
            isCover = false
        }
        
    }
    
    func configure_imgAva(){
        // creating layer that will be applied to avaImageView (layer - broders of ava)
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: imgAva.frame.width, height: imgAva.frame.height)
        imgAva.layer.addSublayer(border)
        
        // rounded corners
        imgAva.layer.cornerRadius = 10
        imgAva.layer.masksToBounds = true
        imgAva.clipsToBounds = true
    }
    
    @objc func imgCoverTapped(){
        imageViewTapped = "cover"
        showActionSheet()
    }
    
    @objc func imgAvaTapped(){
        imageViewTapped = "ava"
        showActionSheet()
    }
    
    func showActionSheet(){
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { action in
            print("go to camera")
            self.openCamera()
        }
        
        let library = UIAlertAction(title: "Library", style: UIAlertAction.Style.default) { action in
            print("go to library")
            self.openPhotoLibrary()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        let delete = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { action in
            print("Delete")
            if self.imageViewTapped == "cover"{
                self.imgCover.image = UIImage(named: "HomeCover.png")
                self.isCover = false
            } else if self.imageViewTapped == "ava" {
                self.imgAva.image = UIImage(named: "user.png")
                self.isAva = false
            }
            
        }
        
        if imageViewTapped == "ava" && isAva == false {
            delete.isEnabled = false
        } else if imageViewTapped == "cover" && isCover == false {
            delete.isEnabled = false
        }
        
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        sheet.addAction(delete)
        self.present(sheet, animated: true, completion: nil)
        
        
    }
    
    func openPhotoLibrary(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func openCamera(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.allowsEditing = true
        self.present(pickerController, animated: true, completion: nil)
    }
    
    // görseli seçtikten sonra imageViewde gözükmesi için
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        
        if imageViewTapped == "cover" {
            self.imgCover.image = image
            //self.uploadImage(from: self.imgCover)
        } else if imageViewTapped == "ava" {
            self.imgAva.image = image
            //self.uploadImage(from: self.imgAva)
        }
        
        self.dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
                self.isCoverChanged = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
                self.isAvaChanged = true
            }
        }
    }
    
    // sends request to the server to upload the Image (ava/cover)
    func uploadImage(from imageView: UIImageView, type: String, completion: @escaping () -> Void) {
        
        // save method of accessing ID of current user
        guard let id = currentUser?["id"] else {
            return
        }
        
        // STEP 1. Declare URL, Request and Params
        // url we gonna access (API)
        let url = URL(string: "http://\(Ip().ip)/fb/uploadImage.php")!
        
        // declaring reqeust with further configs
        var request = URLRequest(url: url)
        
        // POST - safest method of passing data to the server
        request.httpMethod = "POST"
        
        // values to be sent to the server under keys (e.g. ID, TYPE)
        let params = ["id": id, "type": type]
        
        // MIME Boundary, Header
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if in the imageView is placeholder - send no picture to the server
        // Compressing image and converting image to 'Data' type
        var imageData = Data()
        
        if imageView.image != UIImage(named: "HomeCover.jpg") && imageView.image != UIImage(named: "user.png") {
            imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
        }
        
        // assigning full body to the request to be sent to the server
        request.httpBody = Helper().body(with: params, filename: "\(type).jpg", filePathKey: "file", imageDatakey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, vc: self)
                    return
                }
                
                
                do {
                    
                    // save mode of casting any data
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, vc: self)
                        return
                    }
                    
                    // fetching JSON generated by the server - php file
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save method of accessing json constant
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // uploaded successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        // saving upaded user related information (e.g. ava's path, cover's path)
                        // saving updated user related information (e.g. ava's path, cover's path)
                        currentUser = parsedJSON.mutableCopy() as? Dictionary<String, Any>
                        DEFAULTS.set(currentUser, forKey: keyCURRENT_USER)
                        print(parsedJSON)
                        
                        // sending notification to other vcs
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUser"), object: nil)
                        
                        completion()
                        
                        // error while uploading
                    } else {
                        
                        // show the error message in AlertView
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            Helper().showAlert(title: "Error", message: message, vc: self)
                        }
                        
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, vc: self)
                }
                
            }
        }.resume()
        
    }

    
    @IBAction func btnCancel_clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
   
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        
        if textField == txtPassword {
            if isPasswordChanged == false {
                isPasswordChanged = true
            }
        }
        
    }
    
    
    
    
    // number of columns in the gender picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of rows in the gender picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPickerValues.count
    }
    
    // title for the row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPickerValues[row]
    }
    
    // executed when picker selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtGender.text = genderPickerValues[row]
        txtGender.resignFirstResponder()
    }
    
    
  

 

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
    
