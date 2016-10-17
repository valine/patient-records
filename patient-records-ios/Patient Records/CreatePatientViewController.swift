//
//  CreatePatientViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class CreatePatientViewController: UIViewController, UISplitViewControllerDelegate {
    @IBOutlet weak var SymptomSummary: UITextField!

    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 0, height: 14000)
        

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var containerView: UIView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        var patient = Patient.defaultPatient()
        patient.firstName = "Lukas"
        patient.lastName = "Valine"
        patient.sex = 0
        patient.allergies = "None"
        
        PatientRespository.addPatient(json: patient.toDictionary())
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
