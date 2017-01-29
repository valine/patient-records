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
    
    static func getPatientById(id: Int, completion: @escaping (_: [String: Any])->Void, debug: @escaping (_: String)->Void) {
        
    }
    
    static func deletePatientById(id: Int, completion: @escaping (_:Void)->Void) {

    }
    
    static func getPatients(completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
    
    }
    
    static func getRecentPatients(completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
    
    }

    static func searchPatients(input: String, completion: @escaping (_: [Patient])->Void, debug: @escaping (_: String)->Void) {
    
    }
    
    static func addPatient(json: [String: Any], completion: @escaping (_:Void)->Void) {
        
    }
    
    static func updatePatient(json: [String: Any], completion: @escaping (_:Void)->Void) {
        
    }
    
    static func getPatientPhoto(id: String, completion: @escaping (_:UIImage)->Void) {
        
    }
    
    static func getPatientPhotoSmall(id: String, completion: @escaping (_:UIImage)->Void, noImage: @escaping (_:Void)->Void) {
    
    }
    
    static func postImage(id: String, image: UIImage, completion: @escaping (_:Void)->Void) {

    }
    
    
    static func postImageSmall(id: String, image: UIImage, completion: @escaping (_:Void)->Void) {
    
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
