//
//  HomeViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults()
        
        if !userDefaults.bool(forKey: "isNotFirstLaunch") {
            userDefaults.set(true, forKey: "isNotFirstLaunch")
            userDefaults.set(true, forKey: "standalone")
        }


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
