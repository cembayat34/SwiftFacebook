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
    
}
