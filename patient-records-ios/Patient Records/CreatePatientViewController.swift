//
//  CreatePatientViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class CreatePatientViewController: UIViewController, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var SymptomSummary: UITextField!

  //  @IBOutlet weak var scrollView: UIScrollView!
    
    let options = PatientAttributeSettings.getAttributeSettings()

    var patient: Patient? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    @IBOutlet var textViews: [UITextView]!
    
    var sender: HomeTableViewCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // scrollView.contentSize = CGSize(width: 0, height: 14000)
        tableView.delegate = self
        tableView.dataSource = self

    }

    func configureView() {

            
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        let count = options?.count
        return count! + 1 // + 1 for the patient photo cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoHeight: CGFloat = 150
        if indexPath.item == 0 {
            return photoHeight
        } else {
            let option = options?[indexPath.item - 1]
            let height = option?["columnHeight"] as! Int
            return CGFloat(height)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.item == 0 {
           
             let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
            return cell
         
        } else {
            
            let option = options?[indexPath.item - 1]
            let type = option?["type"] as! String
            let title = option?["title"] as! String
        
            if type == "textField" {
                let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextFieldCell
                cell.titleLabel.text = title
                return cell
            
            } else if type == "integerCell" {
                let cell:IntegerCell = tableView.dequeueReusableCell(withIdentifier: type) as! IntegerCell
                let valueKeys = option?["valueKeys"] as! Array<String>
                cell.control.removeAllSegments()
                for key in valueKeys {
                   cell.control.insertSegment(withTitle: key, at: cell.control.numberOfSegments, animated: false)
                }
                
                cell.titleLabel.text = title
                return cell
            } else if type == "textViewCell" {
                let cell:TextViewCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextViewCell
                cell.textView.delegate = self
                cell.titleLabel.text = title
                return cell
            } else if type == "dateCell" {
                let cell:DateCell = tableView.dequeueReusableCell(withIdentifier: type) as! DateCell
                cell.titlelabel.text = title
                return cell
            
            } else {
                let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
                cell.titleLabel.text = title
                return cell
            }
        
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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

    @IBAction func integerCellChanged(_ sender: Any) {
    let toggle = sender as! UISegmentedControl
        
        print(toggle.selectedSegmentIndex)
    }

    @IBAction func textFieldEditingChanged(_ sender: Any) {
        let textField = sender as! UITextField
        
        print(textField.text!)
        
        let cell = textField.superview?.superview
        
        let index = tableView.indexPath(for: cell as! UITableViewCell)?.item
        print(options?[index! - 1]["columnName"] as! String)
    }

    @IBAction func dateValueChanged(_ sender: Any) {
        let dateView = sender as! UIDatePicker
        print(dateView.date)
        
        //let cell = dateView.superclass as! DateCell
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
    }
}
