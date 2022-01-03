//
//  PostVC.swift
//  fb
//
//  Created by cem bayat on 31.12.2021.
//

import UIKit

class PostVC: UIViewController {
    
    @IBOutlet weak var imgAva: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var btnAddPic: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var imgPost: UIImageView!
    var isImgPostSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPost.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteImage))
        imgPost.addGestureRecognizer(gestureRecognizer)
        
        
        configure_imgAva()
        loadUser()
        textView.delegate = self
        
        
        
    }
    
    @objc func deleteImage(){
        
        if isImgPostSelected {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            let btnCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            let btnDelete = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { action in
                self.imgPost.image = UIImage()
                self.isImgPostSelected = false
            }
            sheet.addAction(btnDelete)
            sheet.addAction(btnCancel)
            self.present(sheet, animated: true, completion: nil)
            
        }
        
        
    }
    
    func loadUser(){
        Helper().loadFullName(firstName: currentUser?["firstName"] as! String, lastName: currentUser?["lastName"] as! String, showIn: lblFullName)
        Helper().downloadImage(from: currentUser?["ava"] as! String, showIn: imgAva, orShow: "user.jpg")
    }
    
    
    func configure_imgAva(){
        imgAva.layer.cornerRadius = imgAva.frame.width / 2
        imgAva.clipsToBounds = true
    }
    
    
    @IBAction func btnAddPicClicked(_ sender: Any) {
        showActionSheet()
    }
    
  
    @IBAction func btnCancelClicked(_ sender: Any) {
        
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar")
//        self.present(vc, animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnShareClicked(_ sender: Any) {
        
        guard let id = currentUser!["id"], let text = textView.text else {return}
        let params = ["user_id" : id, "text" : text]
        
        let url = URL(string: "http://\(Ip().ip)/fb/uploadPost.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // web development and MIME Type of passing information to the web server
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // access / convert image to data for sending to the server
        
        var imageData : Data = Data()
        
        if isImgPostSelected {
            imageData = UIImage.jpegData(imgPost.image!)(compressionQuality: 0.5)!
        }
        
        request.httpBody = Helper().body(with: params, filename: "\(NSUUID().uuidString).jpg", filePathKey: "file", imageDatakey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    Helper().showAlert(title: "Server error", message: error!.localizedDescription, vc: self)
                    
                    return
                }
                
                do {
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, vc: self)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    guard let parsedJSON = json else {return}
                    
                    if parsedJSON["status"] as! String == "200" {
                        self.dismiss(animated: true, completion: nil)
                        print(json)
                    } else {
                        Helper().showAlert(title: "Error", message: parsedJSON["message"] as! String, vc: self)
                        return
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON ERROR", message: error.localizedDescription, vc: self)
                }
                
                
                
            }
            
            
        }.resume()
        
        
        
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
        present(pickerController, animated: true, completion: nil)
    }
    
    func openCamera(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    // görseli seçtikten sonra imageViewde gözükmesi için
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        
        imgPost.image = image
        isImgPostSelected = true
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension PostVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.isEmpty == true {
            lblPlaceholder.isHidden = false
        } else {
            lblPlaceholder.isHidden = true
        }
    }
}



extension PostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
}
