//
//  CreatePatientViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class CreatePatientViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var SymptomSummary: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 0, height: 1400)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func savePatientTapped(_ sender: AnyObject) {
    
        var patient = Patient.defaultPatient()
        patient.firstName = "Lukas"
        patient.lastName = "Valine"
        patient.sex = 0
        patient.allergies = "None"
        
        PatientRespository.addPatient(json: patient.toDictionary())
    
    }
    @IBAction func touchUp(_ sender: Any) {
        
        var patient = Patient.defaultPatient()
        patient.firstName = "Lukas"
        patient.lastName = "Valine"
        patient.sex = 0
        patient.allergies = "None"
        
        PatientRespository.addPatient(json: patient.toDictionary())
    
    
    }
}
