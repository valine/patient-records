//
//  HomeViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit
import SpriteKit


class HomeViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, CreatePatientViewContrllerDelegate {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var logoContainerView: UIView!
    
    var logoScene: SKScene?
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
        let welcomeHeaderHeight: CGFloat = 70
        //tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0)
        
        logoScene = SKScene(fileNamed: "LogoScene")!
        let skLogoView = logoContainerView as! SKView
        skLogoView.allowsTransparency = true
        logoScene?.backgroundColor = .clear
        skLogoView.backgroundColor = UIColor.clear
        skLogoView.presentScene(logoScene)
        
        animateHeart()
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchGestureIcon(_:)))
        skLogoView.addGestureRecognizer(tapGesture)
        
        PatientRespository.getRecentPatients(completion: {(returnedPatients) in
            self.patients = returnedPatients
            self.tableView.reloadData()
        }, debug: {(value) in
           
        })
    }
    @IBAction func searchTapped(_ sender: Any) {
    }
    
    
    func touchGestureIcon(_ sender:UITapGestureRecognizer){
        animateHeart()
    }
    
    func animateHeart() {
        if #available(iOS 9.0, *) {
            let logoSprite = logoScene?.childNode(withName: "logo")
            logoSprite?.run(SKAction(named: "heart-beat")!)
            
        } else {
            // Fallback on earlier versions
        }
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
            controller.delegate = self
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if let selectedRow = tableView.indexPathForSelectedRow {
//            tableView.deselectRow(at: selectedRow, animated: true)
//        }
//        
//        PatientRespository.getRecentPatients(completion: {(returnedPatients) in
//            self.patients = returnedPatients
//            self.tableView.reloadData()
//        }, debug: {(value) in
//
//        })
//    }
    
    /// Called when createPatientViewController model view dismisses
    func didFinishTask(sender: CreatePatientViewContrllerDelegate) {
        
        print("delegate!!!!")
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
