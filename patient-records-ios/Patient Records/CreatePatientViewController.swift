//
//  CreatePatientViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class CreatePatientViewController: UITableViewController, UISplitViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var delegate: CreatePatientViewContrllerDelegate?
    let options = PatientAttributeSettings.getAttributeSettings()
    
    var mode: Mode? = Mode.view {
        didSet {
            self.configureView()
        }
    }
    
    var patientDictionary: [String: Any] = Patient.defaultPatientDictionary() {
    
        didSet {
            print("table reload")
            self.tableView?.reloadData()
        }
    }
    
     var patientDictionaryToSave: [String: Any] = Patient.defaultPatientDictionary()


    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    @IBOutlet var textViews: [UITextView]!
    
    var sender: HomeTableViewCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    
    func configureView() {
        if mode == .new {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(CreatePatientViewController.rightNavButtonTapped(_:)))
            navigationItem.rightBarButtonItem = refreshButton
        }
        
        else if mode == .update {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(CreatePatientViewController.rightNavButtonTapped(_:)))
            navigationItem.rightBarButtonItem = refreshButton
        }
        
        else if mode == .view {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(CreatePatientViewController.rightNavButtonTapped(_:)))
            navigationItem.rightBarButtonItem = refreshButton
        }
        
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        let count = options?.count
        
        return count! + 1 // + 1 for the patient photo cell
        
       
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoHeight: CGFloat = 150
        if indexPath.item == 0 {
            return photoHeight
        } else {
            let option = options?[indexPath.item - 1]
            let height = option?["columnHeight"] as! Int
            return CGFloat(height)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        //// New patient
        if mode == .new || mode == .update {
        
            if indexPath.item == 0 {
               
                 let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
                return cell
             
            } else {
                
                let option = options?[indexPath.item - 1]
                let type = option?["type"] as! String
                let title = option?["title"] as! String

                
                if type == "textFieldCell" {
                    let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextFieldCell
                    
                    cell.textField.isHidden = false
                    cell.viewLabel.isHidden = true
                    cell.titleLabel.text = title
                    
                    let columnName = option?["columnName"] as! String
                    let value = patientDictionaryToSave[columnName]

                    cell.textField.text = value as! String?
                   
                    
                    return cell
                
                } else if type == "integerCell" {
                    let cell:IntegerCell = tableView.dequeueReusableCell(withIdentifier: type) as! IntegerCell
                    let valueKeys = option?["valueKeys"] as! Array<String>
                    cell.control.removeAllSegments()
                    
                    for key in valueKeys {
                       cell.control.insertSegment(withTitle: key, at: cell.control.numberOfSegments, animated: false)
                    }
                    
                    cell.titleLabel.text = title
                    let columnName = option?["columnName"] as! String
                    let value = patientDictionaryToSave[columnName]
                    
                    cell.control.selectedSegmentIndex = (value as! Int?)!

                    
                    return cell
                } else if type == "textViewCell" {
                    let cell:TextViewCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextViewCell
                    cell.textView.delegate = self
                    cell.titleLabel.text = title
                   
                    let columnName = option?["columnName"] as! String
                    let value = patientDictionaryToSave[columnName]
                    
                    cell.textView.text = value as! String

                    return cell
                } else if type == "dateCell" {
                    let cell:DateCell = tableView.dequeueReusableCell(withIdentifier: type) as! DateCell
                    cell.titlelabel.text = title
                    return cell
                
                } else {
                    let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "none") as! TextFieldCell
                    cell.titleLabel.text = title
                    return cell
                }
            
            }
        }
        
        /// View Patient
        else {
        

            if indexPath.item == 0 {
               
                 let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
                return cell
             
            } else {
                
                let option = options?[indexPath.item - 1]
                let type = option?["type"] as! String
                let title = option?["title"] as! String
                let columnName = option?["columnName"] as! String
            
                if type == "textFieldCell" {
                    let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextFieldCell
                    
                    cell.textField.isHidden = true
                    cell.viewLabel.isHidden = false
                    
                    if let value = patientDictionary[columnName] as? String {
                            cell.titleLabel.text = title
                            cell.viewLabel.text = value
                    }

    
                    return cell
                
                } else if type == "integerCell" {
                    
                    
                    let cell:IntegerCell = tableView.dequeueReusableCell(withIdentifier: type) as! IntegerCell
                    let valueKeys = option?["valueKeys"] as! Array<String>
                    cell.control.removeAllSegments()
                    for key in valueKeys {
                       cell.control.insertSegment(withTitle: key, at: cell.control.numberOfSegments, animated: false)
                    }
                    
                    cell.control.isHidden = true
                    cell.viewLabel.isHidden = false
                    
                    if let value = patientDictionary[columnName] as? Int {
                            let valueKeys = option?["valueKeys"] as! Array<String>
                            let text = valueKeys[value]
                            cell.titleLabel.text = title
                            cell.viewLabel.text = text
                    }
                    
                    cell.titleLabel.text = title
                    return cell
                    
                } else if type == "textViewCell" {
                    let cell:TextViewCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextViewCell
                    cell.textView.delegate = self
                    cell.titleLabel.text = title
                    
                    if let value = patientDictionary[columnName] as? String {
                        
                        cell.textView.text = value
                    }
                    
                    
                    return cell
                } else if type == "dateCell" {
                    let cell:DateCell = tableView.dequeueReusableCell(withIdentifier: type) as! DateCell
                    cell.titlelabel.text = title
                    
                                        
                    if let value = patientDictionary[columnName] as? Date {
                        print(value)
                        cell.datePicker.date = value
                    }
                    
                    return cell
                
                } else {
                    let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
                    cell.titleLabel.text = title
                    return cell
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    @IBOutlet weak var containerView: UIView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rightNavButtonTapped(_ sender: Any) {
        
        if (mode == .new) {
            PatientRespository.addPatient(json: patientDictionaryToSave, completion: {
                
                self.dismiss(animated: true, completion: {})
                self.delegate?.didFinishTask(sender: self.delegate!)

            })
        } else if mode == .view {
            mode = .update
        } else if mode == .update {
            mode = .view
        }
    }
    @IBAction func cancelTapped(_ sender: Any) {
            self.dismiss(animated: true, completion: nil)
    }


    @IBAction func integerCellChanged(_ sender: Any) {
    let toggle = sender as! UISegmentedControl

        
        let cell = toggle.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = toggle.selectedSegmentIndex

    }


    @IBAction func textFieldEditingChanged(_ sender: Any) {
        let textField = sender as! UITextField

        let cell = textField.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textField.text

    }
    

    @IBAction func dateValueChanged(_ sender: Any) {
        let dateView = sender as! UIDatePicker
        print(dateView.date)
        
        let cell = dateView.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = String(describing: dateView.date)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
                
        let cell = textView.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textView.text
        
    }
    
    
    enum Mode {
        case new
        case view
        case update
    }
    

}

protocol CreatePatientViewContrllerDelegate: class {
    func didFinishTask(sender: CreatePatientViewContrllerDelegate)
}
