//
//  SettingsViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/3/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var standAloneSwitch: UISwitch!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    let emailAddress = "records@valine.io"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults()
        
        let isStandlone = userDefaults.bool(forKey: "standalone")
        standAloneSwitch.isOn = isStandlone
        
        serverAddressField.delegate = self
        serverAddressField.text = userDefaults.string(forKey: "serveraddress")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// MARK: UI interaction

    @IBAction func dismissTapped(_ sender: AnyObject) {
        serverAddressField.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let userDefaults = UserDefaults()

        
        if serverAddressField.text?.lowercased().range(of:"http://") != nil || serverAddressField.text?.lowercased().range(of:"https://") != nil {
            ServerSettings.sharedInstance.serverAddress = URL(string: serverAddressField.text!)
            userDefaults.set(serverAddressField.text, forKey: "serveraddress")
        } else {
            ServerSettings.sharedInstance.serverAddress = URL(string: "http://" + serverAddressField.text!)
            userDefaults.set("http://" + serverAddressField.text!, forKey: "serveraddress")
        }

        return true
    }
    
    @IBAction func standaloneSwitchChanged(_ sender: AnyObject) {
    
        let userDefaults = UserDefaults()
        userDefaults.set(standAloneSwitch.isOn, forKey: "standalone")
        
        PatientAttributeSettings.updateRemoteRecords()
        
    
    
    
        let listPatientsRequest = "patientrecords"
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)

        
        if !standAloneSwitch.isOn {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if let unwrappedData = data {
                    DispatchQueue.main.async {
                        let s1 = String(data: unwrappedData, encoding: String.Encoding.ascii)!
                        
                    }
                } else {
                    
                    
                }
            }
            task.resume()
        }
        
    }
    
    @IBAction func textEntered(_ sender: AnyObject) {
    
        let userDefaults = UserDefaults()
        
        
        if serverAddressField.text?.lowercased().range(of:"http://") != nil || serverAddressField.text?.lowercased().range(of:"https://") != nil {
            ServerSettings.sharedInstance.serverAddress = URL(string: serverAddressField.text!)
            userDefaults.set(serverAddressField.text, forKey: "serveraddress")
        } else {
            ServerSettings.sharedInstance.serverAddress = URL(string: "http://" + serverAddressField.text!)
            userDefaults.set("http://" + serverAddressField.text!, forKey: "serveraddress")
        }
        
        
    }
    
    @IBAction func helpButtonPressed(_ sender: AnyObject) {
    
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    // MARK Mail support stuff
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([emailAddress])
        mailComposerVC.setSubject("Patient Records support request")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
