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
    let options = PatientAttributeSettings.getAttributeSettings()
    
    var mode: Mode? = Mode.view {
        didSet {
            self.configureView()
        }
    }
    
    var patientDictionary: [String: Any] = Patient.defaultPatientDictionary()
    
    var patientDictionaryToSave: [String: Any] = Patient.defaultPatientDictionary()

    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    @IBOutlet var textViews: [UITextView]!
    
    var sender: HomeTableViewCell?
    
    var obscureView: UIView?
    
    var obscure: Bool = false {
        
        didSet {
            if obscure {
                self.obscureView?.alpha = 1
                
            } else {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                    
                    self.obscureView?.alpha = 0
                    
                }, completion: nil)
                
            }
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
    }

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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        let count = options?.count
        
        if mode == .update {
            return count! + 2 // extra one for the delete cell
            
            
        } else {
        
            return count! + 1 // + 1 for the patient photo cell
        }
        
       
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoHeight: CGFloat = 120
        if indexPath.item == 0 {
            return photoHeight
        } else {
            if indexPath.item < (options?.count)! + 1{

                let option = options?[indexPath.item - 1]
                var height = option?["columnHeight"] as! Int
                
                let textFieldHeight = 95
                
                if mode == .view && option?["type"] as! String == "dateCell" {
                    
                    height = textFieldHeight;
                }
                
            return CGFloat(height)
            } else { /// for delete button
                return photoHeight
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if mode == .empty {
            let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
            cell.titleLabel.text = "";
            cell.textField.isHidden = true
            cell.viewLabel.isHidden = true
            return cell
        }
        
        //// New patient
        if mode == .new || mode == .update {
        
            if indexPath.item == 0 {
               
                let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
                
                if mode == .new {
                cell.titleLabel.text = "New Patient Photo"
                } else {
                    cell.titleLabel.text = "Update Patient Photo";
                }
                
                if mode == .update {
                    if let value = patientDictionary["id"] as? Int {
                        PatientRespository.getPatientPhoto(id: String(value), completion: {image in
                            cell.patientPhoto.image = image
                            cell.patientPhoto.contentScaleFactor = 2
                            cell.patientPhoto.layer.cornerRadius = cell.patientPhoto.frame.height / 2
                            cell.patientPhoto.layer.borderWidth = 4
                            cell.patientPhoto.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor
                            
                        })
                    }
                } else {
                    if let imageLocal = imageHold {
                        
                        cell.patientPhoto.image = imageLocal
                        cell.patientPhoto.contentScaleFactor = 2
                        cell.patientPhoto.layer.cornerRadius = cell.patientPhoto.frame.height / 2
                        cell.patientPhoto.layer.borderWidth = 4
                        cell.patientPhoto.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor

                    }
                    
                    
                }

                let imageView = cell.patientPhoto
                let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(selectPicture(_:)))
                imageView?.isUserInteractionEnabled = true
                imageView?.addGestureRecognizer(tapGestureRecognizer)
                

                return cell
             
            } else {
                
                
                if indexPath.item < (options?.count)! + 1 {
                
                    let option = options?[indexPath.item - 1]
                
                    let type = option?["type"] as! String
                    let title = option?["title"] as! String

                
                    if type == "textFieldCell" {
                        let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextFieldCell
                        
                        cell.textField.isHidden = false
                        cell.viewLabel.isHidden = true
                        cell.titleLabel.text = title
                        
                        let columnName = option?["columnName"] as! String
                        let value = patientDictionary[columnName]

                        cell.textField.text = value as! String?
                        cell.viewLabel.text = value as! String?
                        
                        return cell
                    
                    } else if type == "integerCell" {
                        let cell:IntegerCell = tableView.dequeueReusableCell(withIdentifier: type) as! IntegerCell
                        let valueKeys = option?["valueKeys"] as! Array<String>
                        cell.control.removeAllSegments()
                        
                        cell.control.isHidden = false
                        cell.viewLabel.isHidden = true
                        for key in valueKeys {
                           cell.control.insertSegment(withTitle: key, at: cell.control.numberOfSegments, animated: false)
                        }
                        
                        cell.titleLabel.text = title
                        let columnName = option?["columnName"] as! String
                        let value = patientDictionary[columnName]
                        cell.control.selectedSegmentIndex = (value as! Int?)!

                        
                        return cell
                    } else if type == "textViewCell" {
                        let cell:TextViewCell = tableView.dequeueReusableCell(withIdentifier: type) as! TextViewCell
                        cell.textView.delegate = self
                        cell.titleLabel.text = title
                        cell.textView.backgroundColor = #colorLiteral(red: 0.9595803359, green: 0.9690811313, blue: 0.9690811313, alpha: 1)
                        cell.textView.layer.cornerRadius = 5
                        cell.textView.layer.borderWidth = 0.9
                        cell.textView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
                        cell.textView.isEditable = true
                        

                        let columnName = option?["columnName"] as! String
                        let value = patientDictionary[columnName]
                        
                        cell.textView.text = value as! String

                        return cell
                    } else if type == "dateCell" {
                        let cell:DateCell = tableView.dequeueReusableCell(withIdentifier: type) as! DateCell
                        cell.titlelabel.text = title
                        
                        let columnName = option?["columnName"] as! String
                        let value = patientDictionary[columnName] as! String
                       
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        
                        
                        if let date = formatter.date(from: value) {
                            cell.datePicker.setDate(date, animated: false)
                        }
                        
                        cell.viewLabel.isHidden = true;
                        cell.datePicker.isHidden = false;

                        return cell
                    
                    } else {
                        
                            let cell:TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "none") as! TextFieldCell
                            cell.titleLabel.text = title
                            return cell
                        
                    }
                    
                } else {
                    
                        let cell:DeleteCell = tableView.dequeueReusableCell(withIdentifier: "deleteCell") as! DeleteCell
                    cell.delete.addTarget(self, action: #selector(CreatePatientViewController.deletePressed(_:)), for: UIControlEvents.touchUpInside)

                        return cell
                }
            }
        }
        
        /// View Patient
        else {
        

            if
                indexPath.item == 0 {
               
                let cell:PhotoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoCell
                
                cell.titleLabel.text = "Patient Photo"
                
                if let value = patientDictionary["id"] as? Int {
                    PatientRespository.getPatientPhoto(id: String(value), completion: {image in
                        cell.patientPhoto.image = image
                        cell.patientPhoto.contentScaleFactor = 2
                        cell.patientPhoto.layer.cornerRadius = cell.patientPhoto.frame.height / 2
                        cell.patientPhoto.layer.borderWidth = 4
                        cell.patientPhoto.layer.borderColor = #colorLiteral(red: 0.7651372084, green: 0.7957782119, blue: 0.8147243924, alpha: 1).cgColor
                    })
                }
                
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
                    cell.textView.backgroundColor = .white
                    cell.textView.isEditable = false
                    
                    cell.textView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    cell.textView.layer.borderWidth = 0

                    
                    if let value = patientDictionary[columnName] as? String {
                        
                        cell.textView.text = value
                    }
                    
                    
                    return cell
                } else if type == "dateCell" {
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
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = toggle.selectedSegmentIndex
        patientDictionary = patientDictionaryToSave

    }


    @IBAction func textFieldEditingChanged(_ sender: Any) {
        
        let textField = sender as! UITextField

        let cell = textField.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textField.text
        patientDictionary = patientDictionaryToSave

    }
    

    @IBAction func dateValueChanged(_ sender: Any) {
        let dateView = sender as! UIDatePicker
        
        let cell = dateView.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = String(describing: dateView.date)
        patientDictionary = patientDictionaryToSave
        
    }
    
    func textViewDidChange(_ textView: UITextView) {

        let cell = textView.superview?.superview
        let index = self.tableView.indexPath(for: cell as! UITableViewCell)?.item
        let columnName = options?[index! - 1]["columnName"] as! String
        
        patientDictionaryToSave[columnName] = textView.text
        patientDictionary = patientDictionaryToSave
        
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
    
    var imageHold: UIImage?
    
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
        
        let idValue = self.patientDictionary["id"] as! Int;

        let firstName = self.patientDictionary["firstName"] as! String;
        let lastName = self.patientDictionary["lastName"] as! String;
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

    enum Mode {
        case new
        case view
        case update
        case empty
    }

}

protocol CreatePatientViewContrllerDelegate: class {
    func didFinishTask(sender: CreatePatientViewContrllerDelegate, selectId: Int)
}
