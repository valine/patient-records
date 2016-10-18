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
    

    var patient: Patient? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    @IBOutlet var textViews: [UITextView]!
    
    var sender: HomeTableViewCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 0, height: 14000)
        //patient = Patient.defaultPatient()
    }

    func configureView() {
    
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = .none
                textField.backgroundColor = .clear
            }
            
            for segmentedControl in segmentedControls {
                segmentedControl.isEnabled = false
                segmentedControl.backgroundColor = .clear
            }
            
            for textView in textViews {
                textView.isEditable = false
                textView.backgroundColor = .clear
            }
            
            textFields[0].text = patient?.firstName
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
