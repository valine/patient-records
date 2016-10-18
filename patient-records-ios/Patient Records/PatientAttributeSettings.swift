//
//  PatientAttributeSettings.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/17/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation

class PatientAttributeSettings {

    static func getAttributeSettings() -> Array<[String: Any]>?{
        let fileName = "patient-attributes"
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            if let data = NSData(contentsOf: url) {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSDictionary
                    if let options : Array = dictionary?["options"] as? Array<[String: Any]> {
                            for option in options {
                                print(option["title"]!)
                            }
                            return options
                    }
                } catch {
                    print("Error. Unable to parse  \(fileName).json")
                }
            }
        }
        return nil
    }
}
