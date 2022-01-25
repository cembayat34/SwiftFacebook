//
//  NoPicCell.swift
//  fb
//
//  Created by cem bayat on 15.01.2022.
//

import UIKit

class NoPicCell: UITableViewCell {

    @IBOutlet weak var imgAva: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPostText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgAva.layer.cornerRadius = imgAva.frame.width / 2
        imgAva.clipsToBounds = true
    }

  

}
