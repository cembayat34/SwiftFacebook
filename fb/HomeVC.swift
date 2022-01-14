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
    @IBOutlet weak var btnAddBio: UIButton!
    @IBOutlet weak var lblBio: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imgCover.isUserInteractionEnabled = true
        imgAva.isUserInteractionEnabled = true
        lblBio.isUserInteractionEnabled = true
        
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(imgHomeCoverTapped))
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imgUserTapped))
        let gestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(lblBioTapped))
        
        imgCover.addGestureRecognizer(gestureRecognizer1)
        imgAva.addGestureRecognizer(gestureRecognizer2)
        lblBio.addGestureRecognizer(gestureRecognizer3)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateBio"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateUser"), object: nil)

        
        configure_imgUser()
        loadUser()
        
    }
    
    
    @objc func loadUser(){
        
        // safe method of accessing user related informaiton in glob var
        guard let firstName = currentUser?["firstName"],
              let lastName = currentUser?["lastName"],
              let avaPath = currentUser?["ava"],
              let coverPath = currentUser?["cover"],
              let bio = currentUser?["bio"]
        else {
            return
        }
        
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
        
        
        lblFullName.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)"
        
        Helper().downloadImage(from: avaPath as! String, showIn: self.imgAva, orShow: "user.jpg")
        Helper().downloadImage(from: coverPath as! String, showIn: self.imgCover, orShow: "HomeCover.jpg")
        
        if(bio as! String).isEmpty {
            btnAddBio.isHidden = false
            lblBio.isHidden = true
        } else {
            btnAddBio.isHidden = true
            lblBio.isHidden = false
            lblBio.text = bio as? String
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
    
    @objc func lblBioTapped(){
        print("bio")
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let edit = UIAlertAction(title: "New Bio", style: UIAlertAction.Style.default) { action in
            //code
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationBioVC")
            self.present(vc, animated: true, completion: nil)
        }
        
        let delete = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { action in
            //code
            self.deleteBio()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        sheet.addAction(edit)
        sheet.addAction(delete)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
        
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
        let url = URL(string: "http://\(Ip().ip)/fb/uploadImage.php")!
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
                    helper.showAlert(title: "Server Error", message: error!.localizedDescription, vc: self)
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
    
    
    func deleteBio(){
        
        guard let id = currentUser?["id"] else {return}
        
        let bio = String() // empty string
        
        let url = URL(string: "http://\(Ip().ip)/fb/updateBio.php")!
        let body = "id=\(id)&bio=\(bio)"
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
                        print(parsedJSON)
                        
                        if parsedJSON["status"] as! String == "200" {
                            
                            currentUser = parsedJSON.mutableCopy() as? Dictionary<String, Any>
                            DEFAULTS.set(currentUser, forKey: keyCURRENT_USER)
                            
                            // reload user
                            self.loadUser()
                            
                            print(parsedJSON)
                            
                        }
                        
                        

                        
                        
                    } catch {
                        Helper().showAlert(title: "JSON Error", message: error.localizedDescription, vc: self)
                    }
                    
                }
                
                
                
            }
        }.resume()
    }
    
    
    
    
}
