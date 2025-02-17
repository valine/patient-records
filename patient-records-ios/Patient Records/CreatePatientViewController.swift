//
//  CreatePatientViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit
import CoreImage

class CreatePatientViewController: UITableViewController, UISplitViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: CreatePatientViewContrllerDelegate?
    var options: Array<[String: Any]> = [[String: Any]]()
    var patientDictionary: [String: Any] = [String: Any]()
    
    var patientDictionaryToSave: [String: Any] = [String: Any]()

    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    @IBOutlet var textViews: [UITextView]!
    
    var sender: HomeTableViewCell?
    
    var obscureView: UIView?
    
    var obscure: Bool = false {
        
        didSet {
            if obscure {
                
                self.obscureView?.alpha = 1
                self.navigationItem.setHidesBackButton(true, animated:false);
                self.tableView.isScrollEnabled = false
            } else {
                self.tableView.isScrollEnabled = true
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                    
                    self.obscureView?.alpha = 0
                }, completion: { _ in
                    
                     self.navigationItem.setHidesBackButton(false, animated:true);
                })
            }
        }
    }

    enum Mode {
        case new
        case view
        case update
        case empty
    }
    
    var mode: Mode? = Mode.view {
        didSet {
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tableView.allowsSelection = false
        
        obscureView = UIView(frame: self.tableView.frame)
        obscureView?.backgroundColor = .white
        obscureView?.alpha = 0
        self.tableView.addSubview(obscureView!)
        self.hidesBottomBarWhenPushed = false;

        PatientRespository.getAttributeSettings(completion: { attributes in
        
            self.options = attributes

        })
    }
    
    // MARK: TableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if mode == .empty || options.count == 0 {
            return createEmptyCell()
        }
            
        else if indexPath.item == 0 {
            
            return createPhotoCell()
       
        } else if indexPath.item < (options.count) + 1 {
            
            let option = options[indexPath.item - 1]
            
            let type = option["type"] as! String
            let title = option["title"] as! String
            let columnName = option["columnName"] as! String
            let doesPage = false
            //let valueKeys = option?["valueKeys"] as! Array<String>
            
            if type == "textFieldCell" && doesPage {
                return createTextFieldCell(type: type, columnName: columnName, title: title)
                
            } else if type == "textViewCell" && doesPage {
                return createTextViewCell(type: type, columnName: columnName, title: title)
                
            } else if type == "textFieldCell" && !doesPage {
                return createTextFieldCell(type: type, columnName: columnName, title: title)
                
            } else if type == "textViewCell" && !doesPage {
                return createTextViewCell(type: type, columnName: columnName, title: title)
                
            } else if type == "dateCell"{
                return createDateCell(type: type, columnName: columnName, title: title)
                
            } else if type == "integerCell"{
                let valueKeys = option["valueKeys"] as! Array<String>
                return createIntegerCell(type: type, columnName: columnName, title: title, valueKeys: valueKeys)
                
            } else {
                return UITableViewCell()
            }
            
        } else {
            return createDeleteCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = options.count
        
        if mode == .update {
            
            return count + 2 // extra one for the delete cell
        } else {
            
            return count + 1 // + 1 for the patient photo cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoHeight: CGFloat = 135
        if indexPath.item == 0 {
            return photoHeight
        } else {
            if indexPath.item < (options.count) + 1{
                
                let option = options[indexPath.item - 1]
                var height = option["columnHeight"] as! Int
                
                let textFieldHeight = 95
                
                if mode == .view && option["type"] as! String == "dateCell" {
                    
                    height = textFieldHeight;
                }
                
                return CGFloat(height)
            } else { /// for delete button
                return photoHeight
            }
        }
    }

    // MARK: Cells
    
    var imageHold: UIImage?
    
    func createPhotoCell() -> PhotoCell {
        
        let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
        
        cell.dateAdded.text = ""
        
        if mode == .new {
            cell.titleLabel.text = "New Patient Photo"
           
            if let imageLocal = imageHold {
                
                cell.patientPhoto.image = imageLocal
                cell.patientPhoto.contentScaleFactor = 2
                cell.patientPhoto.layer.cornerRadius = cell.patientPhoto.frame.height / 2
                cell.patientPhoto.layer.borderWidth = 4
                cell.patientPhoto.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor
            }
        } else if mode == .update  {
            cell.titleLabel.text = "Update Patient Photo";
            
            // Set date added label
            if let value = patientDictionary["dateAdded"] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd:HH:mm:ss"
                
                if let date = formatter.date(from: value) {
                    let formatterToString = DateFormatter()
                    formatterToString.dateStyle = DateFormatter.Style.short
                    cell.dateAdded.text = "Created " + formatterToString.string(from: date)
                } else {
                    cell.dateAdded.text = "Unknown"
                }
            }
            
            if let value = patientDictionary["id"] as? Int {
                PatientRespository.getPatientPhoto(id: String(value), completion: {image in
                    cell.patientPhoto.image = image
                    cell.patientPhoto.contentScaleFactor = 2
                    cell.patientPhoto.layer.cornerRadius = cell.patientPhoto.frame.height / 2
                    cell.patientPhoto.layer.borderWidth = 4
                    cell.patientPhoto.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor
                    
                })
            }

        } else if mode == .view {

            if let value = patientDictionary["dateAdded"] as? String {
                // cell.datePicker.date = value
                cell.titleLabel.text = "Patient Photo";
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd:HH:mm:ss"
                
                if let date = formatter.date(from: value) {
                    let formatterToString = DateFormatter()
                    formatterToString.dateStyle = DateFormatter.Style.short
                    cell.dateAdded.text = "Created " + formatterToString.string(from: date)
                } else {
                    cell.dateAdded.text = "Unknown"
                }
                
            }
            
            if let value = patientDictionary["id"] as? Int {
                PatientRespository.getPatientPhoto(id: String(value), completion: {image in
                    cell.patientPhoto.image = image
                    cell.patientPhoto.contentScaleFactor = 2
                    cell.patientPhoto.layer.cornerRadius = cell.patientPhoto.frame.height / 2
                    cell.patientPhoto.layer.borderWidth = 4
                    cell.patientPhoto.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor
                })
            }
            if let imageLocal = imageHold {
                
                cell.patientPhoto.image = imageLocal
                cell.patientPhoto.contentScaleFactor = 2
                cell.patientPhoto.layer.cornerRadius = cell.patientPhoto.frame.height / 2
                cell.patientPhoto.layer.borderWidth = 4
                cell.patientPhoto.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor
                
            }
            
            return cell
            
        }
        
        let imageView = cell.patientPhoto
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(selectPicture(_:)))
        imageView?.isUserInteractionEnabled = true
        imageView?.addGestureRecognizer(tapGestureRecognizer)

        return cell;
    }
    
    func createEmptyCell() -> TextFieldCell {
        let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
        cell.titleLabel.text = "";
        cell.textField.isHidden = true
        cell.viewLabel.isHidden = true
        return cell
    }
    
    func createTextFieldCell(type: String, columnName: String, title: String) -> TextFieldCell{
        if mode == .new || mode == .update {
            let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextFieldCell
            
            cell.textField.isHidden = false
            cell.viewLabel.isHidden = true
            cell.titleLabel.text = title
            cell.textField.delegate = self
            
            if mode == .new {
                patientDictionaryToSave[columnName] = "Unknown"
            }
            
            let value = patientDictionaryToSave[columnName]
            cell.textField.text = value as! String?
            cell.viewLabel.text = title
            
            return cell
        } else {
            let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextFieldCell
            
            cell.textField.isHidden = true
            cell.viewLabel.isHidden = false
            
            if let value = patientDictionary[columnName] as? String {
                cell.titleLabel.text = title
                cell.viewLabel.text = value
            }

            return cell
        }

    }
    
    func createIntegerCell(type: String, columnName: String, title: String, valueKeys: Array<String>) -> IntegerCell{
        
        
        if mode == .new || mode == .update {

            let cell:IntegerCell = tableView.dequeueReusableCell(withIdentifier: type) as! IntegerCell
            cell.control.removeAllSegments()
            
            cell.control.isHidden = false
            cell.viewLabel.isHidden = true
            for key in valueKeys {
                cell.control.insertSegment(withTitle: key, at: cell.control.numberOfSegments, animated: false)
            }
            
            cell.titleLabel.text = title
            
            if mode == .new {
                patientDictionaryToSave[columnName] = cell.control.numberOfSegments - 1
                cell.control.selectedSegmentIndex =  cell.control.numberOfSegments - 1
            } else {
                
                cell.control.selectedSegmentIndex = Int(patientDictionaryToSave[columnName] as! String)!
            }
            
            
            return cell
        } else {
            
            let cell:IntegerCell = tableView.dequeueReusableCell(withIdentifier: type) as! IntegerCell
            cell.control.removeAllSegments()
            for key in valueKeys {
                cell.control.insertSegment(withTitle: key, at: cell.control.numberOfSegments, animated: false)
            }
            
            cell.control.isHidden = true
            cell.viewLabel.isHidden = false
            print(patientDictionary[columnName] as! String + "int debug")
            print(valueKeys)
            if let value = Int((patientDictionary[columnName] as! String)) {
                
                print(valueKeys[value])
                let text = valueKeys[value]
                cell.titleLabel.text = title
                cell.viewLabel.text = text
                //cell.control.selectedSegmentIndex = cell.control.numberOfSegments - 1
            }
            
            cell.titleLabel.text = title
            return cell
        }
        
    }
    
    
    func createTextViewCell(type: String, columnName: String, title: String) -> TextViewCell{
        if mode == .new || mode == .update {
            
            let cell:TextViewCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextViewCell
            cell.textView.delegate = self
            cell.titleLabel.text = title
            cell.textView.backgroundColor = #colorLiteral(red: 0.9595803359, green: 0.9690811313, blue: 0.9690811313, alpha: 1)
            cell.textView.layer.cornerRadius = 5
            cell.textView.layer.borderWidth = 0.9
            cell.textView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
            cell.textView.isEditable = true
            
           
            if mode == .new {
                
                patientDictionaryToSave[columnName] = "Unknown"
            }
            
            cell.textView.text = patientDictionaryToSave[columnName] as! String!
            
            return cell

        } else {
            
            let cell:TextViewCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextViewCell
            cell.textView.delegate = self
            cell.titleLabel.text = title
            cell.textView.backgroundColor = .white
            cell.textView.isEditable = false
            
            cell.textView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.textView.layer.borderWidth = 0
            
            if let value = patientDictionary[columnName] as? String {
                cell.textView.text = value
            }
            
            return cell

        }
        
    }
    
    func createDateCell(type: String, columnName: String, title: String) -> DateCell{
        if mode == .new || mode == .update {
            
            let cell:DateCell = tableView.dequeueReusableCell(withIdentifier: type) as! DateCell
            cell.titlelabel.text = title

            let value = "2005-12-12 12:12:12"
            if mode == .new {
                patientDictionaryToSave[columnName] = "Unknown"
            } else {
                let value = patientDictionaryToSave[columnName]
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            
            if let date = formatter.date(from: value) {
                cell.datePicker.setDate(date, animated: false)
            }
            
            cell.viewLabel.isHidden = true;
            cell.datePicker.isHidden = false;
            
            return cell

            
        } else {
            
            let cell:DateCell = tableView.dequeueReusableCell(withIdentifier: type) as! DateCell
            cell.titlelabel.text = title
            cell.viewLabel.isHidden = false;
            cell.datePicker.isHidden = true;
            
            if let value = patientDictionary[columnName] as? String {
                // cell.datePicker.date = value
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                
                if let date = formatter.date(from: value) {
                    let formatterToString = DateFormatter()
                    formatterToString.dateStyle = DateFormatter.Style.full
                    cell.viewLabel.text = formatterToString.string(from: date)
                } else {
                    cell.viewLabel.text = "Unknown"
                }
                
            }
            
            return cell
        }
        
    }
    
    func createDeleteCell() -> DeleteCell{
        
        let cell:DeleteCell = tableView.dequeueReusableCell(withIdentifier: "deleteCell") as! DeleteCell
        cell.delete.addTarget(self, action: #selector(CreatePatientViewController.deletePressed(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }

    @IBOutlet weak var containerView: UIView!
    
    // MARK: Navigation
    
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    
    func configureView() {
        if mode == .empty {
            
            self.navigationItem.setHidesBackButton(false, animated:true);
            navigationItem.leftBarButtonItem = nil
            
            self.navigationController?.navigationController?.navigationBar.barTintColor  = #colorLiteral(red: 0.9450980392, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            self.navigationController?.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6318992972, green: 0.1615979671, blue: 0.2013439238, alpha: 1)
            self.navigationController?.navigationBar.barTintColor  = #colorLiteral(red: 0.9450980392, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6318992972, green: 0.1615979671, blue: 0.2013439238, alpha: 1)
            
            
            self.navigationController?.navigationController?.setToolbarHidden(true, animated: false)
        }
            
        else if mode == .new {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(CreatePatientViewController.rightNavButtonTapped(_:)))
            navigationItem.rightBarButtonItem = refreshButton
            UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.9450980392, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.6318992972, green: 0.1615979671, blue: 0.2013439238, alpha: 1)
            self.navigationController?.setToolbarHidden(true, animated: false)
            
        }
            
        else if mode == .update {
            self.navigationController?.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.354016006, green: 0.37027812, blue: 0.4115960598, alpha: 1)
            self.navigationController?.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9163082838, green: 0.9195989966, blue: 0.9287547469, alpha: 1)
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.354016006, green: 0.37027812, blue: 0.4115960598, alpha: 1)
            
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9163082838, green: 0.9195989966, blue: 0.9287547469, alpha: 1)
            
            patientDictionaryToSave = patientDictionary;
            let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(CreatePatientViewController.cancelTapped(_:)))
            
            navigationItem.leftBarButtonItem = cancelButton
            
            self.navigationItem.setHidesBackButton(true, animated:true);
            
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(CreatePatientViewController.rightNavButtonTapped(_:)))
            navigationItem.rightBarButtonItem = refreshButton
            self.navigationController?.setToolbarHidden(true, animated: true)
            
            
        }
            
        else if mode == .view {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(CreatePatientViewController.rightNavButtonTapped(_:)))
            navigationItem.rightBarButtonItem = refreshButton
            
            self.navigationItem.setHidesBackButton(false, animated:true);
            
            navigationItem.leftBarButtonItem = nil
            
            self.navigationController?.navigationController?.navigationBar.barTintColor  = #colorLiteral(red: 0.9450980392, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            self.navigationController?.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6318992972, green: 0.1615979671, blue: 0.2013439238, alpha: 1)
            self.navigationController?.navigationBar.barTintColor  = #colorLiteral(red: 0.9450980392, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6318992972, green: 0.1615979671, blue: 0.2013439238, alpha: 1)
            self.navigationController?.setToolbarHidden(false, animated: false)
            
            
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func rightNavButtonTapped(_ sender: Any) {
        
        if (mode == .new) {
            PatientRespository.addPatient(json: patientDictionaryToSave, completion: {
                
                if let imageLocal = self.imageHold {
                    PatientRespository.getRecentPatients(completion: { patients in
                        
                        let resizeSmall = PatientRespository.resizeImage(image: imageLocal, targetSize: CGSize(width: 75, height: 75))
                        PatientRespository.postImageSmall(id: String(describing: patients[0].id), image: resizeSmall, completion: {})
                        
                        let resize = PatientRespository.resizeImage(image: imageLocal, targetSize: CGSize(width: 200, height: 200))
                        PatientRespository.postImage(id: String(describing: patients[0].id), image: resize, completion: {
                            self.tableView.reloadData()
                            
                        })

                    }, debug: {_ in })
                    
                }
                
                self.dismiss(animated: true, completion: {})
                self.delegate?.didFinishTask(sender: self.delegate!, selectId: 0)
            })
     
            
        } else if mode == .view {
            mode = .update

            
        } else if mode == .update {
            mode = .view
            
            patientDictionaryToSave["id"] = patientDictionary["id"]
            
            PatientRespository.updatePatient(json: patientDictionaryToSave, completion: {
                
                PatientRespository.getPatientById(id: self.patientDictionary["id"] as! Int, completion: {(patient) in
                    self.patientDictionary = patient
                    
                }, debug: {(debug) in })
                
                self.delegate?.didFinishTask(sender: self.delegate!, selectId: self.patientDictionary["id"] as! Int)
            })
            
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        if mode == .update {
            mode = .view
            
        } else if mode == .new {
            
            self.dismiss(animated: true, completion: {
            })
        }
    }
    
    @IBAction func integerCellChanged(_ sender: Any) {
    let toggle = sender as! UISegmentedControl
        
        
        let cell = toggle.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = toggle.selectedSegmentIndex
        patientDictionary = patientDictionaryToSave

    }


    @IBAction func textFieldEditingChanged(_ sender: Any) {
        
        let textField = sender as! UITextField
        
        let cell = textField.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textField.text
        patientDictionary = patientDictionaryToSave
    }
    

    @IBAction func dateValueChanged(_ sender: Any) {
        let dateView = sender as! UIDatePicker
        
        let cell = dateView.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = String(describing: dateView.date)
        patientDictionary = patientDictionaryToSave
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let cell = textView.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textView.text
        patientDictionary = patientDictionaryToSave
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Unknown" || textView.text == "None" {
            textView.text = ""
        } 
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "Unknown" || textField.text == "None" {
            textField.text = ""
        }
    }
    

    
    func selectPicture(_ sender: AnyObject) {
        
        let ImagePicker = UIImagePickerController()
        ImagePicker.delegate = self
        ImagePicker.sourceType = UIImagePickerControllerSourceType.camera
        
        self.present(ImagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let uiimage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if mode == .update {

            PatientRespository.postImage(id: String(patientDictionaryToSave["id"] as! Int), image: uiimage!, completion: {

                self.tableView.reloadData()
            })
            
            PatientRespository.postImageSmall(id: String(self.patientDictionaryToSave["id"] as! Int), image: uiimage!, completion: {})
        } else if mode == .new {
            let resize = PatientRespository.resizeImage(image: uiimage!, targetSize: CGSize(width: 200, height: 200))
            imageHold = resize
            tableView.reloadData()
        }
        
        
        // image.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    func deletePressed(_ sender: Any) {
        let firstName = patientDictionary["firstName"] as! String
        let lastName = patientDictionary["lastName"] as! String
        let name = firstName + " " +  lastName
        let message = "Are you sure you want to delete " + name + "?  This cannot be easily undone."
        // Create the alert controller
        let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Delete Patient", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.mode = .empty
            
            if let id = self.patientDictionary["id"] {
                
                PatientRespository.deletePatientById(id: id as! Int, completion: {
                    
                    _ = self.navigationController?.navigationController?.popToRootViewController(animated: true)
                    self.delegate?.didFinishTask(sender: self.delegate!, selectId: 0)
                })
                
            } else {
                
                // TODO patient alreay delete alert
            }
           
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in

        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if mode == .update {
            mode = .view;
        }
    }

    @IBAction func wristbandPressed(_ sender: Any) {
        
        if let idAny = self.patientDictionary["id"] {
        
            let idValue = idAny as! Int
        
            if let firstNameString = self.patientDictionary["firstName"], let lastNameString =  self.patientDictionary["lastName"]  {
            let firstName = firstNameString as! String;
            let lastName = lastNameString as! String;
            let fullName = "\(firstName) \(lastName)"

            
            let listPatientsRequest = "patient/id/" + String(idValue)
            let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)


            let data = url.absoluteString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            let holderView = UIView(frame: CGRect(x: 0, y:0, width: 200, height: 10000))
            let wristBandView = WristbandView(frame: CGRect(x:30, y:30, width: 100, height: 1000))
            holderView.addSubview(wristBandView)
            
            let qrcode = filter?.outputImage
            
            let scaleX = wristBandView.imageView.frame.size.width / (qrcode?.extent.size.width)!
            let scaleY = wristBandView.imageView.frame.size.height / (qrcode?.extent.size.height)!
            
            let transformedImage = qrcode?.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            wristBandView.imageView.image = UIImage(ciImage: transformedImage!)
            wristBandView.nameView.text = fullName
            wristBandView.idView.text = "#" + String(idValue)
            
            
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary:nil)
            
            printInfo.outputType = UIPrintInfoOutputType.general
            printInfo.jobName = "print Job"
            printController.printInfo = printInfo
            printController.printingItem = toPDF(views: [holderView])
            
            printController.present(animated: true, completionHandler: nil)
            }
        }
    }
    
    private func toPDF(views: [UIView]) -> NSData? {
        
        if views.isEmpty {
            return nil
        }
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: 612, height: 792), nil)
        
        let context = UIGraphicsGetCurrentContext()
        
        for view in views {
            UIGraphicsBeginPDFPage()
            view.layer.render(in: context!)
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

protocol CreatePatientViewContrllerDelegate: class {
    func didFinishTask(sender: CreatePatientViewContrllerDelegate, selectId: Int)
}

