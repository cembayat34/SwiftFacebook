//
//  HomeVC.swift
//  fb
//
//  Created by cem bayat on 24.12.2021.
//

import UIKit

class HomeVC: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgAva: UIImageView!
    var imageViewTapped : String = ""
    var isCover : Bool = false
    var isAva : Bool = false
    @IBOutlet weak var lblFullName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imgCover.isUserInteractionEnabled = true
        imgAva.isUserInteractionEnabled = true
        
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(imgHomeCoverTapped))
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imgUserTapped))
        
        imgCover.addGestureRecognizer(gestureRecognizer1)
        imgAva.addGestureRecognizer(gestureRecognizer2)
        
        configure_imgUser()
        
        loadUser()
        
    }
    
    
    func loadUser(){
        
        // safe method of accessing user related informaiton in glob var
        guard let firstName = currentUser?["firstName"],
              let lastName = currentUser?["lastName"],
              let avaPath = currentUser?["ava"],
              let coverPath = currentUser?["cover"]
        else {
            return
        }
        
        lblFullName.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)"
        
        downloadImage(from: avaPath as! String, showIn: imgAva)
        downloadImage(from: coverPath as! String, showIn: imgCover)
    }
    
    func downloadImage(from path : String, showIn imageView : UIImageView){
        // if avaPath string having a valid url, IT'S NOT EMPTY (e.g. ava isn't assigned, than in db the link is stored as blank string)
        if String(describing: path).isEmpty == false {
            DispatchQueue.main.async {
                // converting url string to the valid url
                if let url = URL(string: (path as! String)){
                    
                    // downloading all data form URL
                    guard let data = try? Data(contentsOf: url) else {
                        imageView.image = UIImage(named: "user.png")
                        return
                    }
                    
                    // converting downloaded data to the image
                    guard let image = UIImage(data: data) else {
                        imageView.image = UIImage(named: "user.png")
                        return
                    }
                    
                    // assignin image to the imageView
                    imageView.image = image
                }
            }
        }
    }
    
    func configure_imgUser(){
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: imgAva.frame.width, height: imgAva.frame.height)
        imgAva.layer.addSublayer(border)
        
        imgAva.layer.cornerRadius = 10
        imgAva.layer.masksToBounds = true
        imgAva.clipsToBounds = true
    }
    
    @objc func imgHomeCoverTapped(){
        print("cover")
        imageViewTapped = "cover"
        showActionSheet()
    }
    
    @objc func imgUserTapped(){
        print("ava")
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
        let image = info[.editedImage] as? UIImage
        
        if imageViewTapped == "cover" {
            self.imgCover.image = image
            self.uploadImage(from: self.imgCover)
        } else if imageViewTapped == "ava" {
            self.imgAva.image = image
            self.uploadImage(from: self.imgAva)
        }
        
        self.dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
            }
        }
    }
    
    
    func uploadImage(from imageView: UIImageView) {
        
        let helper = Helper()
        
        // güvenilir yoldan currentUserin idsine erişme
        guard let id = currentUser?["id"] else {
            return
        }
        
        // STEP 1. Declare URL, Request and Pararameters
        // url
        let url = URL(string: "http://192.168.1.34/fb/uploadImage.php")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        // values to be sent to the server under keys (e.g. ID, TYPE)
        let params = ["id" : id, "type": imageViewTapped]
        
        // MIME Boundary, Header
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Compressing image and converting image to 'Data' type
        let imageData = UIImage.jpegData(imageView.image!)(compressionQuality: 0.5)!
        
        // Assigning full body to the request to be sent to the server
        request.httpBody = Helper().body(with: params, filename: "\(imageViewTapped).jpg", filePathKey: "file", imageDatakey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                
                
                if error != nil {
                    helper.showAlert(title: "Data Error", message: error!.localizedDescription, vc: self)
                    return
                }
                
                do {
                    // save mode of casting any data
                    guard let data = data else {
                        helper.showAlert(title: "Data Error", message: error?.localizedDescription ?? "Eroor", vc: self)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                    
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    //uploaded successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        // saving updated user related information (e.g. ava's path, cover's path)
                        currentUser = parsedJSON.mutableCopy() as? Dictionary<String, Any>
                        DEFAULTS.set(currentUser, forKey: keyCURRENT_USER)
                        print(parsedJSON)
                    } else {
                        // show the error message in alertView
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            helper.showAlert(title: "Error", message: message, vc: self)
                        }
                    }
                    
                } catch {
                   
                    helper.showAlert(title: "JSON Error", message: error.localizedDescription, vc: self)
                }
                
            }
            
        }.resume()
        
    }
    
    
    
    
}
