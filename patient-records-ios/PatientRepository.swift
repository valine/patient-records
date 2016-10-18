//
//  PatientRepository.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/4/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation

class PatientRespository {

    static func getPatientById(id: Int, completion: @escaping (_: [String: Any])->Void, debug: @escaping (_: String)->Void) {
        
        let listPatientsRequest = "patient/id/" + String(id)
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let unwrappedData = data {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: unwrappedData, options: .allowFragments) as! [String: Any]
                        
                        let returnedPatient = Patient.newFromJSON(json: json)
        
                        completion(json)
                        debug("sent patient with name: " + String(returnedPatient.firstName))
                    } catch {
                        print("error serializing JSON: \(error)")
                    } 
                }
            } else {
                DispatchQueue.main.async {
                    debug("Error")
                }
            }
        }
        task.resume()

    }
    
    static func getPatients(completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        let listPatientsRequest = "patient"
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)


        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let unwrappedData = data {
                DispatchQueue.main.async {
                    let returnedPatients = Patient.newArrayFromJSON(data: unwrappedData)
                    completion(returnedPatients)
                }
            } else {
                DispatchQueue.main.async {
                    debug("Error")
                }
            }
        }
        task.resume()
    }
    
    static func getRecentPatients(completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        let listPatientsRequest = "patient/recent"
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
        
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if let unwrappedData = data {
                    DispatchQueue.main.async {
                        let returnedPatients = Patient.newArrayFromJSON(data: unwrappedData)
                        completion(returnedPatients)
                    }
                } else {
                    DispatchQueue.main.async {
                        debug("Error")
                    }
                }
            }
            task.resume()
    }
    
    static func searchPatients(input: String, completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        let listPatientsRequest = "patient/search/" + input
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
            
        let urlWithPort = NSURLComponents(string: url.absoluteString)
        urlWithPort?.port = ServerSettings.port;
    
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if let unwrappedData = data {
                    DispatchQueue.main.async {
                        let returnedPatients = Patient.newArrayFromJSON(data: unwrappedData)
                        completion(returnedPatients)
                    }
                } else {
                    DispatchQueue.main.async {
                        debug("Error")
                    }
                }
            }
            task.resume()
    }
    
    static func addPatient(json: [String: Any]) {

        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            
            print(jsonData)
            // create post request
            let listPatientsRequest = "patient/add"
            let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)

            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"

            // insert json data to the request
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let theJSONText = String(data: jsonData, encoding: String.Encoding.utf8)
            
            print(theJSONText!)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }

                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]

                    print("Result -> \(result)")

                } catch {
                    print("Error -> \(error)")
                }
            }

            task.resume()

        } catch {
            print(error)
        }
    
    }
}

struct Patient {
    var id: Int
    var dateAdded: Date
    var lastSeen: Date
    
    var firstName: String
    var middleName: String
    var lastName: String
    var sex: UInt8 // 0 unknown, 1 male, 2 female, 9 not applicable
    var birthDate: Date
    
    var phoneNumber: String
    var emailAddress: String
    var weight: [PatientWeight] // in kilograms
    var height: [PatientHeight]
    
    var familyStatus: UInt8 // 0 unknown, 1 known, 2 mother only, 3 father only, 4 other
    
    var medicalIssues: String
    var currentMedications: String
    var previouslMedicalProblems: String
    var previousSurgery: String
    var allergies: String
    
    var medicalRecomedations: [MedicalRecomendations]
    var updates: [Updates]
    
    static func defaultPatient() -> Patient{
        return Patient(
            id: 0,
            dateAdded: Date(),
            lastSeen: Date(),
            
            firstName: "unknown",
            middleName: "unknown",
            lastName: "unknown",
            
            sex: 0,
            birthDate: Date(),
            phoneNumber: "unknown",
            emailAddress: "unknown",
            weight: [PatientWeight](),
            height: [PatientHeight](),
            
            familyStatus: 0,
            
            medicalIssues: "unknown",
            currentMedications: "unknown",
            previouslMedicalProblems: "unknown",
            previousSurgery: "unknown",
            allergies: "unknwon",
            
            medicalRecomedations: [MedicalRecomendations](),
            updates: [Updates]()
        )
    }
    
    static func defaultPatientDictionary() -> [String: Any] {
        let options = PatientAttributeSettings.getAttributeSettings()
        var patient: [String : Any] = [:]
        for option in options! {
        
            let columnName = option["columnName"] as! String
            let type = option["type"] as! String
            
            if type == "integerCell" {
                let defaultValue = option["defaultValue"] as! Int
                patient[columnName] = defaultValue
            } else {
                let defaultValue = option["defaultValue"] as! String
                patient[columnName] = defaultValue
            
            }
        }
        
        return patient
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "dateAdded":  String(describing: self.dateAdded),
            "lastSeen":  String(describing: self.lastSeen),
            "firstName": self.firstName,
            "middleName": self.middleName,
            "lastName": self.lastName,
            "sex": self.sex,
            "birthDate": String(describing: self.birthDate),
            "phoneNumber": self.phoneNumber,
            "emailAddres": self.emailAddress,
            "medicalIssues": self.medicalIssues,
            "currentMedications": self.currentMedications,
            "previousMedicalProblems": self.previouslMedicalProblems,
            "previousSurgery": self.previousSurgery,
            "allergies": self.allergies
        ]
    }
    
    static func newFromJSON(json: [String: Any]) -> Patient {

        var patient = Patient.defaultPatient()
 
        if let firstname = json["firstName"] as? String {
            patient.firstName = firstname
            print(firstname)
        }
        
        if let id = json["id"] as? Int {
            patient.id = id
        }
        
        if let dateAdded = json["dateAdded"] as? Date {
            patient.dateAdded = dateAdded
        }

        return patient
    }
    
    static func newArrayFromJSON(data: Data) -> [Patient] {
        var patientObjects = [Patient]()

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            
            if let jsonPatients = json["patients"] as? [[String: Any]] {
                for jsonPatient in jsonPatients {
                    let patient = Patient.newFromJSON(json: jsonPatient)
                    patientObjects.append(patient)
                }
                
                 print("hello" + String(jsonPatients.count))
            }
            
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        return patientObjects
    }
}


struct PatientWeight {
    var weight: Double
    var date: Date
}

struct PatientHeight {
    var height: Double
    var date: Date
}

struct MedicalRecomendations {
    var recomendation: String
    var date: Date
}

struct Updates {
    var update: String
    var date: Date
}

