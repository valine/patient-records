//
//  TextFieldCell.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/17/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation
import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var viewLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
