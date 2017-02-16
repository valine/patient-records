//
//  PatientRepository.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/4/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class PatientRespository {

    
    static func getPatientById(id: Int, completion: @escaping (_: [String: Any])->Void, debug: @escaping (_: String)->Void) {
        if !UserDefaults().bool(forKey: "standalone") {
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
        } else {
            PatientRespositoryLocal.getPatientById(inputId: id, completion: { patient in
            
                completion(patient)
            
            
            }, debug: {_ in })
        }
    }
    
    static func deletePatientById(id: Int, completion: @escaping (_:Void)->Void) {
        if !UserDefaults().bool(forKey: "standalone") {
            do {

                // create post request
                let listPatientsRequest = "patient/id/" + String(id)
                let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
                
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "DELETE"
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if error != nil{
                        print("Error -> \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                
                task.resume()
                
            }
        } else {
            PatientRespositoryLocal.deletePatientById(inputId: id, completion: {
                
                completion()
            })
        }
        
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
        
        if !UserDefaults().bool(forKey: "standalone") {
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
                            debug("Unable to connect to patient server")
                        }
                    }
                }
                task.resume()
        } else {
            
            PatientRespositoryLocal.getRecentPatients(completion: {patients in
                completion(patients)
            }, debug: {_ in })
            
        }
    }
    
    
    static func getMostRecentPatient(completion: @escaping (_: [String: Any])->Void, debug: @escaping (_: String)->Void) {
        let listPatientsRequest = "patient/mostrecent"
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
    
    static func searchPatients(input: String, completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
        
        if !UserDefaults().bool(forKey: "standalone") {

            let listPatientsRequest = "search/" + input
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
        } else {
            
            PatientRespositoryLocal.searchPatients(input: input, completion: { patients in
                completion(patients)
                
                
            }, debug: {_ in })
            
        }
    }
        
    
    static func addPatient(json: [String: Any], completion: @escaping (_:Void)->Void) {

        if !UserDefaults().bool(forKey: "standalone") {

            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: json)
                
                // create post request
                let listPatientsRequest = "patient/add"
                let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)

                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"

                // insert json data to the request
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let theJSONText = String(data: jsonData, encoding: String.Encoding.utf8)

                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if error != nil{
                        print("Error -> \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }

                task.resume()

            } catch {
                print(error)
            }
        } else {
            
            PatientRespositoryLocal.addPatient(json: json, completion: {
                
                completion()
                
            })
            
        }
    
    }
    
    static func updatePatient(json: [String: Any], completion: @escaping (_:Void)->Void) {
        if !UserDefaults().bool(forKey: "standalone") {
        
            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: json)

                // create post request
                let listPatientsRequest = "patient/update"
                let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
                
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                
                // insert json data to the request
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let theJSONText = String(data: jsonData, encoding: String.Encoding.utf8)
                
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if error != nil{
                        print("Error -> \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                
                task.resume()
                
            } catch {
                print(error)
            }
        } else {
            PatientRespositoryLocal.updatePatient(json: json, completion: {
                
                completion()
                
            })
            
            
        }
        
    }
    
    static func getPatientPhoto(id: String, completion: @escaping (_:UIImage)->Void) {
        
        if !UserDefaults().bool(forKey: "standalone") {
        
            let listPatientsRequest = "patient/photo/\(id)"
            let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
            
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if data != nil {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data!) {
                            completion(image)
                        }
                        
                    }
                }
            }
            task.resume()
            
        } else {
            PatientRespositoryLocal.getPatientPhoto(id: id, completion: { image in

                completion(image)
            })
            
            
        }
    }
    
    static func getPatientPhotoSmall(id: String, completion: @escaping (_:UIImage)->Void, noImage: @escaping (_:Void)->Void) {
        
        if !UserDefaults().bool(forKey: "standalone") {
        let listPatientsRequest = "patient/photosmall/\(id)"
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
        
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if data != nil {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data!) {
                        completion(image)
                    } else {
                        
                        noImage()
                    }
                    
                }
            }
        }
        task.resume()
        } else {
            
            PatientRespositoryLocal.getPatientPhotoSmall(id: id, completion: {
                
                image in
                
                completion(image)
            
            }, noImage: {
                
                noImage()
            
            })
            
        }
    }
    

    /// Create request
    ///
    /// - parameter userid:   The userid to be passed to web service
    /// - parameter password: The password to be passed to web service
    /// - parameter email:    The email address to be passed to web service
    ///
    /// - returns:            The NSURLRequest that was created
    
    static func postImage(id: String, image: UIImage, completion: @escaping (_:Void)->Void) {
        if !UserDefaults().bool(forKey: "standalone") {
            let parameters = [
                "id"  : id]  // build your dictionary however appropriate
            
            let boundary = generateBoundaryString()
            
            let listPatientsRequest = "photo/"
            let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"

            let resize = resizeImage(image: image, targetSize: CGSize(width: 200, height: 200))
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = createBody(with: parameters, filePathKey: "file", images: [resize], boundary: boundary)
            
            

            let session = URLSession.shared


            let task = session.dataTask(with: request as URLRequest, completionHandler: {
                ( data, response, error) in
                
                completion()

                guard ((data) != nil), let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }

                if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                {
                    
                }
                
            })
            
            task.resume()
        } else {
            
            PatientRespositoryLocal.postImage(id: id, image: image, completion: {
                
                completion()
                
                
            })
            
        }
    }
    
    
    static func postImageSmall(id: String, image: UIImage, completion: @escaping (_:Void)->Void) {
        
        if !UserDefaults().bool(forKey: "standalone") {
            let parameters = [
                "id"  : id]  // build your dictionary however appropriate
            
            let boundary = generateBoundaryString()
            
            let listPatientsRequest = "photosmall/"
            let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            
            let resize = resizeImage(image: image, targetSize: CGSize(width: 75, height: 75))
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = createBody(with: parameters, filePathKey: "file", images: [resize], boundary: boundary)
        
            let session = URLSession.shared
            
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {
                ( data, response, error) in
                
                completion()
                
                guard ((data) != nil), let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                
                if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                {
                    

                }
                
            })
            
            task.resume()
        } else {
            
            PatientRespositoryLocal.postImageSmall(id: id, image: image, completion: {
                
                
                completion()
            })
            
            
        }
    }
    
    /// Create body of the multipart/form-data request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The multipart/form-data boundary
    ///
    /// - returns:                The NSData of the body of the request
    
    static func createBody(with parameters: [String: String]?, filePathKey: String, images: [UIImage], boundary: String) -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for image in images {
            
            
            let data = UIImagePNGRepresentation(image)
            let mimetype = "image/png"
                
                //mimeType(for: path)
            let filename = "file"
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data!)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// - parameter path:         The path of the file for which we are going to determine the mime type.
    ///
    /// - returns:                Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    
    static func mimeType(for path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
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

struct Patient {
    var id: Int
    var dateAdded: Date
    var firstName: String
    var lastName: String

    
    static func defaultPatient() -> Patient{
        return Patient(
            id: 0,
            dateAdded: Date(),
            firstName: "",
            lastName: ""
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

    
    static func newFromJSON(json: [String: Any]) -> Patient {

        var patient = Patient.defaultPatient()
 
        if let firstname = json["firstName"] as? String {
            patient.firstName = firstname
        }
        
        if let lastname = json["lastName"] as? String {
            patient.lastName = lastname

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
            }
            
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        return patientObjects
    }
}

extension Data {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
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

