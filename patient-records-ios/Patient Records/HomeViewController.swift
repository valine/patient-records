//
//  HomeViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var patientTable: UITableView!
    @IBOutlet weak var devLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults()
        
        if !userDefaults.bool(forKey: "isNotFirstLaunch") {
            userDefaults.set(true, forKey: "isNotFirstLaunch")
            userDefaults.set(true, forKey: "standalone")
        }
        
        patientTable.delegate = self
        patientTable.dataSource = self


        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    @IBAction func devRefreshPressed(_ sender: AnyObject) {
    
          PatientRespository.getPatientById(id: 10, completion: {(value) in
                self.devLabel.text = value
          })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
