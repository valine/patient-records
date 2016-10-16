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
                   
                     print(String(data: unwrappedData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
                        let returnedPatient = Patient.newFromJSON(data: unwrappedData)
                        completion(returnedPatient)
                        debug("sent patient with name: " + String(returnedPatient.firstName))
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
    
    static func newFromJSON(data: Data) -> Patient {

        var patient = Patient.defaultPatient()
        
        do {
        
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String: Any]]
     
            if let name = json[0]["name"] as? String {
                patient.firstName = name
                print(name)
            }
            
            if let id = json[0]["id"] as? Int {
                patient.id = id
            }
            
            if let dateAdded = json[0]["dateAdded"] as? Date {
                patient.dateAdded = dateAdded
            }
            
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        return patient
    }
    
    static func newArrayFromJSON(data: Data) -> [Patient] {
        var patientObjects = [Patient]()
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            
            if let jsonPatients = json["patients"] as? [Data] {
                for jsonPatient in jsonPatients {
                    let patient = Patient.newFromJSON(data: jsonPatient)
                    patientObjects.append(patient)
                }
            }
        } catch {
            print("error serializing JSON: \(error)")
        }
        return patientObjects
    }
}

@available(*, deprecated)
struct PatientWeight {
    var weight: Double
    var date: Date
}

@available(*, deprecated)
struct PatientHeight {
    var height: Double
    var date: Date
}

@available(*, deprecated)
struct MedicalRecomendations {
    var recomendation: String
    var date: Date
}

@available(*, deprecated)
struct Updates {
    var update: String
    var date: Date
}

