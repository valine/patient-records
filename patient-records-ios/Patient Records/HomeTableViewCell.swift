//
//  HomeTableViewCell.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/11/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1)
        self.selectedBackgroundView = bgColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
