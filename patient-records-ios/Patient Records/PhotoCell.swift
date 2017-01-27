//
//  PhotoCell.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/18/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation

import UIKit

class PhotoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var patientPhoto: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
