//
//  SettingsViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/3/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var standAloneSwitch: UISwitch!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults()
        
        let isStandlone = userDefaults.bool(forKey: "standalone")
        standAloneSwitch.isOn = isStandlone
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismissTapped(_ sender: AnyObject) {
    
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    @IBAction func standaloneSwitchChanged(_ sender: AnyObject) {
    
        let userDefaults = UserDefaults()
        userDefaults.set(standAloneSwitch.isOn, forKey: "standalone")
    }

}
