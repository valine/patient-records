//
//  PatientAttributeSettings.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/17/16.
//  Copyright © 2016 Lukas Valine. All rights reserved.
//

import Foundation

class PatientAttributeSettings {
    
    static var remoteRecords: Array<[String: Any]>? = nil
    
    
    static func updateRemoteRecords() {

            let listPatientsRequest = "config"
            let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if let unwrappedData = data {
                    DispatchQueue.main.async {
                        do {
                            
                            let dictionary = try JSONSerialization.jsonObject(with: unwrappedData as Data, options: .allowFragments) as? NSDictionary
                            if let options : Array = dictionary?["options"] as? Array<[String: Any]> {
                                
                                remoteRecords = options
                            }
                        } catch {
                            print("error serializing JSON: \(error)")
                        }
                    }
                }
            }
            task.resume()

    }

    static func getAttributeSettings() -> Array<[String: Any]>?{
        
        if UserDefaults().bool(forKey: "standalone") || remoteRecords == nil{

            let fileName = "patient-attributes"
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                if let data = NSData(contentsOf: url) {
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSDictionary
                        if let options : Array = dictionary?["options"] as? Array<[String: Any]> {

                                return options
                        }
                    } catch {
                        print("Error. Unable to parse  \(fileName).json")
                    }
                }
            }
            return nil
        } else {
            
            return remoteRecords
            
        }
    }
}
