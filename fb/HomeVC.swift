//
//  HomeVC2.swift
//  fb
//
//  Created by cem bayat on 15.01.2022.
//

import UIKit

class HomeVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgAva: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var btnAddBio: UIButton!
    @IBOutlet weak var lblBio: UILabel!
    
    var imageViewTapped : String = ""
    var isCover : Bool = false
    var isAva : Bool = false
    
    // post obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 10
    var isLoading = false
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)

        configure_imgUser()
        loadUser()
        loadPosts(offset: skip, limit: limit)
    }
    
    @objc func loadNewPosts(){
        loadPosts(offset: 0, limit: skip + 1)
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
    
    
    
    // loading posts from the server via PHP protocol
    func loadPosts(offset : Int, limit : Int){
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://\(Ip().ip)/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                if error != nil {
                    return
                }
                
                do {
                    
                    // access data - safe mode
                    guard let data = data else {
                        Helper().showAlert(title: "Data error", message: error?.localizedDescription ?? "data error", vc: self)
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    // accessing json data - safe mode
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        return
                    }
                    
                    print(posts)
                    
                    self.posts = posts
                    self.skip = posts.count
                    self.tableView.reloadData()
                    
                } catch{
                    Helper().showAlert(title: "JSON error", message: error.localizedDescription, vc: self)
                    return
                }
                
            }
            
        }.resume()
    }
    
    
    
    // loading more posts from the server via PHP protocol
    func loadMore(offset : Int, limit : Int){
        
        isLoading = true
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://\(Ip().ip)/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                if error != nil {
                    self.isLoading = false
                    return
                }
                
                do {
                    
                    // access data - safe mode
                    guard let data = data else {
                        self.isLoading = false
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    // accessing json data - safe mode
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    print(posts)
                    
                    self.posts.append(contentsOf: posts)
                    self.skip += posts.count
                    
                    self.tableView.beginUpdates()
                    
                    for i in 0 ..< posts.count{
                        let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: UITableView.RowAnimation.fade)
                    }
                    
                    self.tableView.endUpdates()
                    
                    self.isLoading = false
                    
                } catch{
                    self.isLoading = false
                    return
                }
            }
        }.resume()
    }
    
    
    
    
    // exec-d  whenever new cell is to be displayed
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
        let pictureURL = posts[indexPath.row]!["picture"] as! String
        
        // no picture in the post
        if pictureURL.isEmpty {
            
            // accessing the cell from main.storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPicCell", for: indexPath) as! NoPicCell
            
            // fullname logic
            let firstName = posts[indexPath.row]!["firstName"] as! String
            let lastName = posts[indexPath.row]!["lastName"] as! String
            cell.lblFullName.text = firstName.capitalized + " " + lastName.capitalized
            
            
            // date logic
            let dateString = posts[indexPath.row]!["date_created"] as! String
            
            // taking the date received from the server and putting it in the following format to be recognized as being Date()
            let formatterGet = DateFormatter()
            formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatterGet.date(from: dateString)!
            
            // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
            let formatterShow = DateFormatter()
            formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
            cell.lblDate.text = formatterShow.string(from: date)
            
            
            // text logic
            let text = posts[indexPath.row]!["text"] as! String
            cell.lblPostText.text = text
            
            
            // avas logic
            let avaString = posts[indexPath.row]!["ava"] as! String
            let avaURL = URL(string: avaString)!
            
            // if there are still avas to be loaded
            if posts.count != avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.avas.append(image)
                            print("AVA assigned")
                            
                            DispatchQueue.main.async {
                                cell.imgAva.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.avas.append(image)
                        print("AVA loaded")
                        
                        DispatchQueue.main.async {
                            cell.imgAva.image = image
                        }
                    }
                    
                }.resume()
                
                // cached ava
            } else {
                print("AVA cached")
                
                DispatchQueue.main.async {
                    cell.imgAva.image = self.avas[indexPath.row]
                }
            }
            
            // picture logic
            pictures.append(UIImage())
            
            // picture in the post
        } else {
            
            // accessing the cell from main.storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "PicCell", for: indexPath) as! PicCell
            
            // fullname logic
            let firstName = posts[indexPath.row]!["firstName"] as! String
            let lastName = posts[indexPath.row]!["lastName"] as! String
            cell.lblFullName.text = firstName.capitalized + " " + lastName.capitalized
            
            // date logic
            let dateString = posts[indexPath.row]!["date_created"] as! String
            
            // taking the date received from the server and putting it in the following format to be recognized as being Date()
            let formatterGet = DateFormatter()
            formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatterGet.date(from: dateString)!
            
            // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
            let formatterShow = DateFormatter()
            formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
            cell.lblDate.text = formatterShow.string(from: date)
            
            // text logic
            let text = posts[indexPath.row]!["text"] as! String
            cell.lblPostText.text = text
            
            // avas logic
            let avaString = posts[indexPath.row]!["ava"] as! String
            let avaURL = URL(string: avaString)!
            
            // if there are still avas to be loaded
            if posts.count != avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.avas.append(image)
                            print("AVA assigned")
                            
                            DispatchQueue.main.async {
                                cell.imgAva.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.avas.append(image)
                        print("AVA loaded")
                        
                        DispatchQueue.main.async {
                            cell.imgAva.image = image
                        }
                    }
                }.resume()
                
                // cached ava
            } else {
                print("AVA cached")
                
                DispatchQueue.main.async {
                    cell.imgAva.image = self.avas[indexPath.row]
                }
            }
            
            // pictures logic
            // avas logic
            let pictureString = posts[indexPath.row]!["picture"] as! String
            let pictureURL = URL(string: pictureString)!
            
            // if there are still pictures to be loaded
            if posts.count != pictures.count {
                
                URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.pictures.append(image)
                            print("PIC assigned")
                            
                            DispatchQueue.main.async {
                                cell.imgPostPic.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.pictures.append(image)
                        print("PIC loaded")
                        
                        DispatchQueue.main.async {
                            cell.imgPostPic.image = image
                        }
                    }
                    
                }.resume()
                
                // cached picture
            } else {
                print("PIC cached")
                
                DispatchQueue.main.async {
                    cell.imgPostPic.image = self.pictures[indexPath.row]
                }
            }
        }
    }
    
    
    
    
    
    
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && isLoading == false {
            loadMore(offset: skip, limit: limit)
        }
        
    }
    
    
    
    // number of posts
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
        let pictureURL = posts[indexPath.row]!["picture"] as! String
        
        // no picture in the post
        if pictureURL.isEmpty {
            
            
            // accessing the cell from main.storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPicCell", for: indexPath) as! NoPicCell
            
            
            // fullname logic
            let firstName = posts[indexPath.row]!["firstName"] as! String
            let lastName = posts[indexPath.row]!["lastName"] as! String
            cell.lblFullName.text = firstName.capitalized + " " + lastName.capitalized
            
            
            // date logic
            let dateString = posts[indexPath.row]!["date_created"] as! String
            
            // taking the date received from the server and putting it in the following format to be recognized as being Date()
            let formatterGet = DateFormatter()
            formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatterGet.date(from: dateString)!
            
            // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
            let formatterShow = DateFormatter()
            formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
            cell.lblDate.text = formatterShow.string(from: date)
            
            
            // text logic
            let text = posts[indexPath.row]!["text"] as! String
            cell.lblPostText.text = text
            
            
            // avas logic
            let avaString = posts[indexPath.row]!["ava"] as! String
            let avaURL = URL(string: avaString)!
            
            // if there are still avas to be loaded
            if posts.count != avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.avas.append(image)
                            print("AVA assigned")
                            
                            DispatchQueue.main.async {
                                cell.imgAva.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.avas.append(image)
                        print("AVA loaded")
                        
                        DispatchQueue.main.async {
                            cell.imgAva.image = image
                        }
                    }
                    
                }.resume()
                
                // cached ava
            } else {
                print("AVA cached")
                
                DispatchQueue.main.async {
                    cell.imgAva.image = self.avas[indexPath.row]
                }
            }
            
            // picture logic
            pictures.append(UIImage())
            return cell
            
            // picture in the post
        } else {
            
            
            // accessing the cell from main.storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "PicCell", for: indexPath) as! PicCell
            
            
            // fullname logic
            let firstName = posts[indexPath.row]!["firstName"] as! String
            let lastName = posts[indexPath.row]!["lastName"] as! String
            cell.lblFullName.text = firstName.capitalized + " " + lastName.capitalized
            
            
            // date logic
            let dateString = posts[indexPath.row]!["date_created"] as! String
            
            // taking the date received from the server and putting it in the following format to be recognized as being Date()
            let formatterGet = DateFormatter()
            formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatterGet.date(from: dateString)!
            
            // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
            let formatterShow = DateFormatter()
            formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
            cell.lblDate.text = formatterShow.string(from: date)
            
            
            // text logic
            let text = posts[indexPath.row]!["text"] as! String
            cell.lblPostText.text = text
            
            
            // avas logic
            let avaString = posts[indexPath.row]!["ava"] as! String
            let avaURL = URL(string: avaString)!
            
            // if there are still avas to be loaded
            if posts.count != avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.avas.append(image)
                            print("AVA assigned")
                            
                            DispatchQueue.main.async {
                                cell.imgAva.image = image
                            }
                            
                        }
                        
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.avas.append(image)
                        print("AVA loaded")
                        
                        DispatchQueue.main.async {
                            cell.imgAva.image = image
                        }
                    }
                }.resume()
                
                // cached ava
            } else {
                print("AVA cached")
                
                DispatchQueue.main.async {
                    cell.imgAva.image = self.avas[indexPath.row]
                }
            }
            
            
            // pictures logic
            // avas logic
            let pictureString = posts[indexPath.row]!["picture"] as! String
            let pictureURL = URL(string: pictureString)!
            
            // if there are still pictures to be loaded
            if posts.count != pictures.count {
                
                URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.pictures.append(image)
                            print("PIC assigned")
                            
                            DispatchQueue.main.async {
                                cell.imgPostPic.image = image
                            }
                            
                        }
                        
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.pictures.append(image)
                        print("PIC loaded")
                        
                        DispatchQueue.main.async {
                            cell.imgPostPic.image = image
                        }
                    }
                    
                }.resume()
                
                // cached picture
            } else {
                print("PIC cached")
                
                DispatchQueue.main.async {
                    cell.imgPostPic.image = self.pictures[indexPath.row]
                }
            }
            return cell
        }
    }
    
    
    
    
    
    
    
}
