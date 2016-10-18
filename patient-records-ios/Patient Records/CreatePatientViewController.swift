//
//  CreatePatientViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

class CreatePatientViewController: UIViewController, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var SymptomSummary: UITextField!

  //  @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var patientTableView: UITableView!
    
    let options = PatientAttributeSettings.getAttributeSettings()
    
    var mode: Mode? = Mode.view {
        didSet {
            self.configureView()
        }
    }
    
    var patientDictionary: [String: Any] = Patient.defaultPatientDictionary() {
    
        didSet {
            print("table reload")
            patientTableView?.reloadData()
        }
    }
    
     var patientDictionaryToSave: [String: Any] = Patient.defaultPatientDictionary()


    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    @IBOutlet var textViews: [UITextView]!
    
    var sender: HomeTableViewCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // scrollView.contentSize = CGSize(width: 0, height: 14000)
        patientTableView.delegate = self
        patientTableView.dataSource = self

    }

    func configureView() {
        if mode == .new {
        
        }
        
        else if mode == .update {
        
        }
        
        else if mode == .view {
        
        }
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
    
        if mode == .new {
        
            if indexPath.item == 0 {
               
                 let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
                return cell
             
            } else {
                
                let option = options?[indexPath.item - 1]
                let type = option?["type"] as! String
                let title = option?["title"] as! String
            
                if type == "textField" {
                    let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextFieldCell
                    
                    cell.textField.isHidden = false
                    cell.viewLabel.isHidden = true
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
        } else {

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
                        let dateFormatter = DateFormatter()
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

    @IBAction func saveTapped(_ sender: Any) {
        PatientRespository.addPatient(json: patientDictionaryToSave)
         self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func integerCellChanged(_ sender: Any) {
    let toggle = sender as! UISegmentedControl
        
        print(toggle.selectedSegmentIndex)
        
        let cell = toggle.superview?.superview
        let index = patientTableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = toggle.selectedSegmentIndex

    }

    @IBAction func textFieldEditingChanged(_ sender: Any) {
        let textField = sender as! UITextField

        let cell = textField.superview?.superview
        let index = patientTableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textField.text

    }

    @IBAction func dateValueChanged(_ sender: Any) {
        let dateView = sender as! UIDatePicker
        print(dateView.date)
        
        let cell = dateView.superview?.superview
        let index = patientTableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = String(describing: dateView.date)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
                
        let cell = textView.superview?.superview
        let index = patientTableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textView.text
        
    }
    enum Mode {
        case new
        case view
        case update
    }
}
