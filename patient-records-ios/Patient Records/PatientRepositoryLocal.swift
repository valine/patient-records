//
//  PatientRepositoryLocal.swift
//  Patient Records
//
//  Created by Lukas Valine on 1/29/17.
//  Copyright © 2017 Lukas Valinevaline. All rights reserved.
//

import Foundation
import SQLite
import UIKit

class PatientRespositoryLocal {
    
    static func createDatabase() {
        
        let options = PatientAttributeSettings.getAttributeSettings()
        
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let patients = Table("patients")
            let id = Expression<Int64>("id")
            let dateAdded = Expression<Int64>("dateAdded")

            do {
                
                try db.run(patients.create { t in
                    t.column(id, primaryKey: .autoincrement)
                    t.column(dateAdded)
                    
                    for option in options! {
                        
                        let type = option["type"] as! String
                        let columnName = option["columnName"] as! String
                        
                        if  type == "textFieldCell" {
                            //print(columnName)
                            let column = Expression<String?>(columnName)
                            t.column(column)
                        }
                        
                        else if  type == "textViewCell" {
                           // print(columnName)
                            let column = Expression<String?>(columnName)
                            t.column(column)
                        }
                        
                        else if  type == "integerCell" {
                            //print(columnName)
                            let column = Expression<Int64?>(columnName)
                            t.column(column)
                        }
                        
                        else if  type == "dateCell" {
                           // print(columnName)
                            let column = Expression<String?>(columnName)
                            t.column(column)
                        }
                    }
                    
                })} catch { print("error creating table")}

            
        } catch {print("error create database")}

        
    }
    
    static func getPatientById(inputId: Int, completion: @escaping (_: [String: Any])->Void, debug: @escaping (_: String)->Void) {
        
        let options = PatientAttributeSettings.getAttributeSettings()
    
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            
            let db = try Connection("\(path)/db.sqlite3")
            let patients = Table("patients")
            let id = Expression<Int64>("id")
            let dateAdded = Expression<String>("dateAdded")

            
            let patientFromDb = try db.pluck(patients.filter(id == Int64(inputId)))
                
            var patient = [String: Any]()
            
            patient["id"] = Int((patientFromDb?[id])! as Int64)
            patient["dateAdded"] = (patientFromDb?[dateAdded])!
            
            for option in options! {
                let type = option["type"] as! String

                    if type == "integerCell" {
                        let columnName = option["columnName"] as! String
                        let column = Expression<Int64?>(columnName)
                        
                        patient[columnName] = Int((patientFromDb?[column])! as Int64)

                    } else {
                    
                        let columnName = option["columnName"] as! String
                        let column = Expression<String?>(columnName)
                        
                        patient[columnName] = patientFromDb?[column]
                    }
            }
            
            completion(patient)  
            
        } catch {}
    }
    
    static func deletePatientById(inputId: Int, completion: @escaping (_:Void)->Void) {
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            
            let db = try Connection("\(path)/db.sqlite3")
            let patients = Table("patients")
            let id = Expression<Int64>("id")
            
            
            try db.run(patients.filter(id == Int64(inputId)).delete())
            
            completion()
            
        } catch {}
    }

    static func getRecentPatients(completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            
        let db = try Connection("\(path)/db.sqlite3")
        let patients = Table("patients")
        let id = Expression<Int64>("id")
        let firstName = Expression<String?>("firstName")
        let lastName = Expression<String?>("lastName")
        let dateAdded = Expression<String?>("dateAdded")
        
        
        let query = patients.select(id, dateAdded, firstName, lastName)           // SELECT "email" FROM "users"
            .order(id.desc) // ORDER BY "email" DESC, "name"
            .limit(15, offset: 0)
            
            
            var patientObjects = [Patient]()
            for patient in try db.prepare(query) {
                
                var patientDictionary = [String: Any]()
                patientDictionary["firstName"] = patient[firstName]
                patientDictionary["lastName"] = patient[lastName]
                patientDictionary["id"] = Int(patient[id])
                print("id" + String(patient[id]))
                patientDictionary["dateAdded"] = patient[dateAdded]
                
                let patientObject = Patient.newFromJSON(json: patientDictionary)
                
                patientObjects.append(patientObject)
            }
            

            completion(patientObjects)
          
            
        } catch {}
    
    }

    static func searchPatients(input: String, completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            
            let db = try Connection("\(path)/db.sqlite3")
            let patients = Table("patients")
            let id = Expression<Int64>("id")
            let firstName = Expression<String?>("firstName")
            let lastName = Expression<String?>("lastName")
            let dateAdded = Expression<String?>("dateAdded")
            
            
            let query = patients
                .select(id, dateAdded, firstName, lastName)
                .filter(firstName.like("%" + input + "%") || lastName.like("%" + input + "%"))
                .order(id.desc) // ORDER BY "email" DESC, "name"
            
            
            var patientObjects = [Patient]()
            for patient in try db.prepare(query) {
                
                var patientDictionary = [String: Any]()
                patientDictionary["firstName"] = patient[firstName]
                patientDictionary["lastName"] = patient[lastName]
                patientDictionary["id"] = Int(patient[id])
                print("id" + String(patient[id]))
                patientDictionary["dateAdded"] = patient[dateAdded]
                
                let patientObject = Patient.newFromJSON(json: patientDictionary)
                
                patientObjects.append(patientObject)
            }
            
            
            completion(patientObjects)
            
            
        } catch {}
    
    }
    
    static func addPatient(json: [String: Any], completion: @escaping (_:Void)->Void) {
        
        let options = PatientAttributeSettings.getAttributeSettings()
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            

            let db = try Connection("\(path)/db.sqlite3")
            let patients = Table("patients")
            
            
            // insert
            var setters = [Setter]()
            
            for option in options! {
                
                let type = option["type"] as! String
                let columnName = option["columnName"] as! String
                
                if  type == "textFieldCell" {
                    let column = Expression<String?>(columnName)
                    setters.append(column <- json[columnName] as! String?)
                }
                    
                else if  type == "textViewCell" {
                    let column = Expression<String?>(columnName)
                    setters.append(column <- json[columnName] as! String?)
                }
                    
                else if  type == "integerCell" {
                    let column = Expression<Int64?>(columnName)
                    setters.append(column <- Int64(json[columnName] as! Int))
                }
                    
                else if  type == "dateCell" {
                    let column = Expression<String?>(columnName)
                    setters.append(column <- json[columnName] as! String?)
                }
                
                
            }
        
            let column = Expression<String?>("dateAdded")
            setters.append(column <- getDateTime())

            
            let insert = patients.insert(setters)
            
            
            
            //let insert = patients.insert(firstName <- "Alice", lastName <- "alice@mac.com")
            try db.run(insert)
            
            completion()
            
        } catch {}
        

        
    }
    
    static func getDateTime() -> String {
        
        let date = Date()
        let calendar = NSCalendar.current

        var components = DateComponents()
        
//        components.hour = calendar.component(.hour, from: date as Date)
//        components.minute = calendar.component(.minute, from: date as Date)
//        components.second = calendar.component(.second, from: date as Date)
//        components.year = calendar.component(.year, from: date as Date)
//        components.month = calendar.component(.month, from: date as Date)
//        components.day = calendar.component(.day, from: date as Date)

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy:MM:dd:HH:mm:ss"
        
        let dateString = dayTimePeriodFormatter.string(from: date)
        print(dateString)
        return dateString;
        
    }
    
    static func updatePatient(json: [String: Any], completion: @escaping (_:Void)->Void) {
        
        let inputId = json["id"] as! Int
        
        let options = PatientAttributeSettings.getAttributeSettings()
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            
            
            let db = try Connection("\(path)/db.sqlite3")
            let patients = Table("patients")
            let id = Expression<Int64>("id")
            
            
            // insert
            var setters = [Setter]()
            
            for option in options! {
                
                let type = option["type"] as! String
                let columnName = option["columnName"] as! String
                
                if  type == "textFieldCell" {
                    let column = Expression<String?>(columnName)
                    setters.append(column <- json[columnName] as! String?)
                }
                    
                else if  type == "textViewCell" {
                    let column = Expression<String?>(columnName)
                    setters.append(column <- json[columnName] as! String?)
                }
                    
                else if  type == "integerCell" {
                    let column = Expression<Int64?>(columnName)
                    setters.append(column <- Int64(json[columnName] as! Int))
                }
                    
                else if  type == "dateCell" {
                    let column = Expression<String?>(columnName)
                    setters.append(column <- json[columnName] as! String?)
                }
                
                
            }
            
            let patient = patients.filter(id == Int64(inputId))
            let update = patient.update(setters)


            try db.run(update)
            
            completion()
            
        } catch {}
    }
    
    static func getPatientPhoto(id: String, completion: @escaping (_:UIImage)->Void) {
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("\(id).png")
            let image    = UIImage(contentsOfFile: imageURL.path)
            
            if let uImage = image {

            completion(uImage)
                
            }
            // Do whatever you want with the image
        }
        
    }
    
    static func getPatientPhotoSmall(id: String, completion: @escaping (_:UIImage)->Void, noImage: @escaping (_:Void)->Void) {
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("\(id)-small.png")
            let image    = UIImage(contentsOfFile: imageURL.path)
            
            if let uImage = image {
                completion(uImage)
                
                
            } else {
                
                
                noImage()
            }
            
            // Do whatever you want with the image
        }
        
    
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func postImage(id: String, image: UIImage, completion: @escaping (_:Void)->Void) {

        let resize = resizeImage(image: image, targetSize: CGSize(width: 200, height: 200))

        if let data = UIImagePNGRepresentation(resize) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(id).png")
            try? data.write(to: filename)
        }
        
        completion()
    }
    
    
    static func postImageSmall(id: String, image: UIImage, completion: @escaping (_:Void)->Void) {
        let resize = resizeImage(image: image, targetSize: CGSize(width: 75, height: 75))
        
        if let data = UIImagePNGRepresentation(resize) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(id)-small.png")
            try? data.write(to: filename)
        }
        
        completion()
    
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
}
