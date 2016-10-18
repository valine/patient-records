//
//  TextViewCell.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/17/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation
import UIKit

class TextViewCell: UITableViewCell {

    @IBOutlet var textView: [UITextView]!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
