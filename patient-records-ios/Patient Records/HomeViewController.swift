//
//  HomeViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit
import SpriteKit


class HomeViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, CreatePatientViewContrllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var logoContainerView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    var searching: Bool = false {
        
        didSet {
            
            if searching {
                beginSearch()
                
            } else {
                
                endSearch()
            }
            
        }
    }
    
    var logoScene: SKScene?
    //var detailViewController: CreatePatientViewController!
    
    let cellReuseIdentifier = "homeCell"
    var patients = [Patient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBarView.alpha  = 0

        searchBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActive(notification:)), name: Notification.Name("didBecomeActive"), object: nil)
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(HomeViewController.updateTable), userInfo: nil, repeats: true)
        
        let userDefaults = UserDefaults()
        
        if !userDefaults.bool(forKey: "isNotFirstLaunch") {
            userDefaults.set(true, forKey: "isNotFirstLaunch")
            userDefaults.set(true, forKey: "standalone")
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        logoScene = SKScene(fileNamed: "LogoScene")!
        let skLogoView = logoContainerView as! SKView
        skLogoView.allowsTransparency = true
        logoScene?.backgroundColor = .clear
        skLogoView.backgroundColor = UIColor.clear
        skLogoView.presentScene(logoScene)
        
        animateHeartWithDelay()
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchGestureIcon(_:)))
        skLogoView.addGestureRecognizer(tapGesture)
        
        
        PatientRespository.getRecentPatients(completion: {(returnedPatients) in
            self.patients = returnedPatients
            self.tableView.reloadData()
        }, debug: {(value) in
           
        })
    }
    
    func updateTable() {
        
        let ipath = tableView.indexPathForSelectedRow;
  
        
        if !searching {
            PatientRespository.getRecentPatients(completion: {(returnedPatients) in
                self.patients = returnedPatients
                self.tableView.reloadData()
                
                self.tableView.selectRow(at: ipath, animated: false, scrollPosition: .none)
            }, debug: {(value) in
                
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let ipath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: ipath, animated: false)
        }
        updateTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let ipath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: ipath, animated: false)
        }
    }
    
    func didBecomeActive(notification: Notification){
        updateTable()
        

    }
    

    func touchGestureIcon(_ sender:UITapGestureRecognizer){
        animateHeart()
        updateTable()
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func searchTapped(_ sender: Any) {
        searching = !searching
        
    }
    
    func searchBarCancelButtonClicked(_ notSearchBar: UISearchBar) {
        searching = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        PatientRespository.searchPatients(input: searchBar.text!, completion: { (returnedPatients) in
            self.patients = returnedPatients
            self.tableView.reloadData()
            
        }, debug: {_ in 
            
            
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        PatientRespository.searchPatients(input: searchBar.text!, completion: { (returnedPatients) in
            self.patients = returnedPatients
            self.tableView.reloadData()
            
        }, debug: {_ in
            
            
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text!)
        PatientRespository.searchPatients(input: searchBar.text!, completion: { (returnedPatients) in
            self.patients = returnedPatients
            self.tableView.reloadData()
            
        }, debug: {_ in
            
            
        })
    }
    @IBOutlet weak var searchBarView: UIView!
    
    func endSearch() {
        
        if !searching {
            self.searchBar.resignFirstResponder()
            self.searchBar.endEditing(true)
            let animationDuration: TimeInterval = 0.2;
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                
                self.headerView.center.y  -=  self.headerView.bounds.height
                self.searchBarView.alpha  = 0
                
            }, completion: nil)
            updateTable()
        }
    }
    
    
    func beginSearch() {
        
        if searching {
            let animationDuration: TimeInterval = 0.2;
            searchBar.isHidden = false;
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                
                self.headerView.center.y  +=  self.headerView.bounds.height
                self.searchBar.becomeFirstResponder()
                self.searchBarView.alpha  = 1
                
            }, completion: nil)
        }
        
    }
    
    func animateHeart() {
        if #available(iOS 9.0, *) {
            let logoSprite = logoScene?.childNode(withName: "logo")
            logoSprite?.run(SKAction(named: "heart-beat")!)
            
        } else {
            // Fallback on earlier versions
        }
    }
    func animateHeartWithDelay() {
        if #available(iOS 9.0, *) {
            let logoSprite = logoScene?.childNode(withName: "logo")
            logoSprite?.run(SKAction(named: "app-load")!)
            
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
        PatientRespository.getPatientPhotoSmall(id: String(patient.id
        ), completion: { image in
            cell.photo.image = image
            cell.photo.contentScaleFactor = 2
            cell.photo.layer.cornerRadius = cell.photo.frame.height / 2
            cell.photo.layer.borderWidth = 2
            cell.photo.layer.borderColor = #colorLiteral(red: 0.7323010564, green: 0.7356925607, blue: 0.7439760566, alpha: 1).cgColor

            
        }, noImage: {
        
            cell.photo.image = #imageLiteral(resourceName: "empty-profile-image-thumbnail")
        })
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
                
                controller.obscure = true
                //controller.patientDictionary = Patient.defaultPatientDictionary()
                
                PatientRespository.getPatientById(id: id!, completion: {(patient) in
                    controller.patientDictionary = patient
                    controller.obscure = false
                    controller.tableView.reloadData();
                }, debug: {(debug) in })
                
        
            }
        } else if segue.identifier == "newPatient" {
        
            let controller = (segue.destination as! UINavigationController).topViewController as! CreatePatientViewController
            
            controller.mode = .new
            controller.delegate = self
        }
    }
    
    /// Called when createPatientViewController model view dismisses
    func didFinishTask(sender: CreatePatientViewContrllerDelegate, selectId: Int) {

       updateTable()
        
    }
    
    enum SearchMode {
        
        case enabled
        case disabled
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
