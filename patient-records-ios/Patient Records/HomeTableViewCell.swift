//
//  HomeTableViewCell.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/11/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var patientName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
