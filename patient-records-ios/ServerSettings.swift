//
//  ServerSettings.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/4/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation

class ServerSettings {
    var serverAddress: URL?
    static let port: NSNumber = 8081
    
    let defaultUrl = URL(string: "http://1uk45.com")
    //MARK: Shared Instance
    static let sharedInstance : ServerSettings = {
        let instance = ServerSettings()
        return instance
    }()

    init() {
        let userDefaults = UserDefaults()
        
        if let theAddress = userDefaults.string(forKey: "serveraddress") {
            serverAddress = URL(string: theAddress)
        } else {
            userDefaults.set("http://1uk45.com", forKey: "serveraddress")
            serverAddress = URL(string: "http://1uk45.com:8081")
        }
    }
    
    func getServerAddress() -> URL {
    
        if let address = NSURLComponents(string: (serverAddress?.absoluteString)!) {
            address.port = ServerSettings.port
            
            if let url = address.url {
                return url
            } else {
                return defaultUrl!
            }
            
        } else {
            return defaultUrl!
        }
    }
}
