//
//  Helper.swift
//  fb
//
//  Created by cem bayat on 23.12.2021.
//

import Foundation
import UIKit


class Helper {
    
    func showAlert(title : String, message : String, vc : UIViewController) {
        
        let alert  = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(okBtn)
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    //MIME for the Image
    func body(with parameters : [String : Any]?, filename: String, filePathKey: String?, imageDatakey: Data, boundary: String) -> NSData {
        
        let body = NSMutableData()
        
        // MIME Type for Parameters [id: 777, name: micheal]
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        //MIME Type for Image
        let mimetype = "image/jpg"
        
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(imageDatakey)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
        
    }
    
    
    
    
    func downloadImage(from path : String, showIn imageView : UIImageView, orShow placeholder: String){
        // if avaPath string having a valid url, IT'S NOT EMPTY (e.g. ava isn't assigned, than in db the link is stored as blank string)
        if String(describing: path).isEmpty == false {
            DispatchQueue.main.async {
                // converting url string to the valid url
                if let url = URL(string: (path as! String)){
                    
                    // downloading all data form URL
                    guard let data = try? Data(contentsOf: url) else {
                        imageView.image = UIImage(named: placeholder)
                        return
                    }
                    
                    // converting downloaded data to the image
                    guard let image = UIImage(data: data) else {
                        imageView.image = UIImage(named: placeholder)
                        return
                    }
                    
                    // assignin image to the imageView
                    imageView.image = image
                }
            }
        }
    }
    
}
