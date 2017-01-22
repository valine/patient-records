//
//  HomeViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit
import SpriteKit


class HomeViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var logoContainerView: UIView!
    
    //var detailViewController: CreatePatientViewController!
    
    let cellReuseIdentifier = "homeCell"
    var patients = [Patient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults()
        
        if !userDefaults.bool(forKey: "isNotFirstLaunch") {
            userDefaults.set(true, forKey: "isNotFirstLaunch")
            userDefaults.set(true, forKey: "standalone")
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        let welcomeHeaderHeight: CGFloat = 100
        tableView.contentInset = UIEdgeInsetsMake(welcomeHeaderHeight + self.topLayoutGuide.length, 0, 0, 0)
        
        let logoScene = SKScene(fileNamed: "LogoScene")
        let skLogoView = logoContainerView as! SKView
        skLogoView.allowsTransparency = true
        logoScene?.backgroundColor = .clear
        skLogoView.backgroundColor = UIColor.clear
        skLogoView.presentScene(logoScene)
        
        PatientRespository.getRecentPatients(completion: {(returnedPatients) in
            self.patients = returnedPatients
            self.tableView.reloadData()
        }, debug: {(value) in
           
        })
    }
    @IBAction func searchTapped(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:HomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HomeTableViewCell!
        let patient = patients[indexPath.item]
        cell.name.text = patient.firstName + " " + patient.lastName
        cell.id.text = String(patient.id)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            
                let cell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
                let id = Int(cell.id.text!)
                
                let controller = (segue.destination as! UINavigationController).topViewController as! CreatePatientViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.mode = .view

                PatientRespository.getPatientById(id: id!, completion: {(patient) in
                    controller.patientDictionary = patient

                }, debug: {(debug) in })
        
            }
        } else if segue.identifier == "newPatient" {
        
            let controller = (segue.destination as! UINavigationController).topViewController as! CreatePatientViewController
            
            controller.mode = .new
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
        
        PatientRespository.getRecentPatients(completion: {(returnedPatients) in
            self.patients = returnedPatients
            self.tableView.reloadData()
        }, debug: {(value) in

        })
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
