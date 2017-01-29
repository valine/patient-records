//
//  WristbandView.swift
//  Patient Records
//
//  Created by Lukas Valine on 1/29/17.
//  Copyright © 2017 Lukas Valinevaline. All rights reserved.
//

import UIKit

class WristbandView: UIView {
    let imageView: UIImageView
    let nameView: UILabel
    let idView: UILabel
    let appIconView: UIImageView
    
    override init(frame: CGRect) {
        
        let center  = frame.width / 2
        
        imageView = UIImageView(frame: CGRect(x: center - (90 / 2), y: 120, width: 90, height: 90))
        appIconView = UIImageView(frame: CGRect(x: center - (30 / 2), y: 5, width: 30, height: 30))
        appIconView.image =  #imageLiteral(resourceName: "wristbandlogo")
        nameView = UILabel(frame: CGRect(x: 5, y:72, width: 90, height: 50))
        nameView.lineBreakMode = .byWordWrapping
        nameView.numberOfLines = 3
        idView = UILabel(frame: CGRect(x: 5, y:50, width: 100, height: 50))
        nameView.font = UIFont.boldSystemFont(ofSize: 10)
        
        super.init(frame: frame)

        self.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor

        self.layer.borderWidth = 2

        
        self.addSubview(imageView)
        self.addSubview(nameView)
        self.addSubview(idView)
        self.addSubview(appIconView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
