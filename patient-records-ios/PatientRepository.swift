//
//  PatientRepository.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/4/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation

class PatientRespository {

    static func getPatientById(id: Int, completion: @escaping (_: Patient)->Void, debug: @escaping (_: String)->Void) {
        
        let listPatientsRequest = "patient/id/" + String(id)
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)!
            
        let urlWithPort = NSURLComponents(string: url.absoluteString)
        urlWithPort?.port = ServerSettings.port;
    
        if let theUrl = urlWithPort?.url {
            let task = URLSession.shared.dataTask(with: (theUrl) as URL) {(data, response, error) in
                if let unwrappedData = data {
                    DispatchQueue.main.async {
                        do {
                            let json = try JSONSerialization.jsonObject(with: unwrappedData, options: .allowFragments) as! [String: Any]
                            let returnedPatient = Patient.newFromJSON(json: json)
                            completion(returnedPatient)
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
        
        } else {
            DispatchQueue.main.async {
                debug("Looks like you didn't enter a server address.")
            }
        }
    }
    
    static func getPatients(completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        let listPatientsRequest = "patient"
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)!
            
        let urlWithPort = NSURLComponents(string: url.absoluteString)
        urlWithPort?.port = ServerSettings.port;
    
        if let theUrl = urlWithPort?.url {
            let task = URLSession.shared.dataTask(with: (theUrl) as URL) {(data, response, error) in
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
        
        } else {
            DispatchQueue.main.async {
                debug("Looks like you didn't enter a server address.")
            }
        }
    }
    
    static func getRecentPatients(completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        let listPatientsRequest = "patient/recent"
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)!
            
        let urlWithPort = NSURLComponents(string: url.absoluteString)
        urlWithPort?.port = ServerSettings.port;
    
        if let theUrl = urlWithPort?.url {
            let task = URLSession.shared.dataTask(with: (theUrl) as URL) {(data, response, error) in
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
        
        } else {
            DispatchQueue.main.async {
                debug("Looks like you didn't enter a server address.")
            }
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
    
    func toJSON() -> JSONSerialization {

        return JSONSerialization()
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

