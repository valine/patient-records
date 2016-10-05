//
//  PatientRepository.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/4/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation

class PatientRespository {

    static func getPatientById(id: Int, completion: @escaping (_: String)->Void) {
        
            let listPatientsRequest = "list_patient_names"
            let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)!
                
            let urlWithPort = NSURLComponents(string: url.absoluteString)
            urlWithPort?.port = ServerSettings.port;
        
            if let theUrl = urlWithPort?.url {
                let task = URLSession.shared.dataTask(with: (theUrl) as URL) {(data, response, error) in
                    
                    if let unwrappedData = data {
                        DispatchQueue.main.async {
                            
                            print(JSONToPatients(data: unwrappedData))
                            completion(String(data: unwrappedData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
                        }
                        
                    } else {
                    
                        DispatchQueue.main.async {
                        print(url.absoluteString)
                            completion("No server found 🙁")
                        }
                    }
                }

                task.resume()
            
            } else {
                DispatchQueue.main.async {
                completion("Looks like you didn't enter a server address.")
            }
        
        }
    }
    
    static func JSONToPatients(data: Data) -> [Patient] {

        
        var patientObjects = [Patient]()
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            
            if let jsonPatients = json["patients"] as? [[String: AnyObject]] {
                for jsonPatient in jsonPatients {
                    
                    var patient = Patient.defaultPatient()
                    
                    if let name = jsonPatient["name"] as? String {
                        patient.name = name
                        print(name)
                    }
                    
                    patientObjects.append(patient)
                }
            }
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        return patientObjects
                
    }
}


struct Patient {
    var id: Int
    var name: String
    var sex: UInt8 // 0 unknown, 1 male, 2 female, 9 not applicable
    var birthDate: Date
    var weight: [PatientWeight] // in kilograms
    var familyStatus: UInt8 // 0 unknown, 1 known, 2 mother only, 3 father only, 4 other
    var medicalIssues: String
    var currentMedications: String
    var previouslMedicalProblems: String
    var previousSurgery: String
    var medicalRecomedations: [MedicalRecomendations]
    var updates: [Updates]
    var height: Double // in inches
    var dateAdded: Date
    

    var allergies: String
    
    static func defaultPatient() -> Patient{
        return Patient(
        id: 0, name: "unknown",
        sex: 0,
        birthDate: Date(),
        weight: [PatientWeight](),
        familyStatus: 0,
        medicalIssues: "unknown",
        currentMedications: "unknown",
        previouslMedicalProblems: "unknown",
        previousSurgery: "unknown",
        medicalRecomedations: [MedicalRecomendations](),
        updates: [Updates](),
        height: 0,
        dateAdded: Date(),
        allergies: "unknwon")
    }
}


struct PatientWeight {
    var weight: Double
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

