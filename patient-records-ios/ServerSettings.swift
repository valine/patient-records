//
//  ServerSettings.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/4/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import Foundation

class ServerSettings {

    var serverAddress: NSURL?
    
    //MARK: Shared Instance

    static let sharedInstance : ServerSettings = {
        let instance = ServerSettings()
        return instance
    }()

    //MARK: Init

    init() {
        let userDefaults = UserDefaults()
        
        if let theAddress = userDefaults.string(forKey: "serveraddress") {
            serverAddress = NSURL(string: theAddress)
        } else {
            userDefaults.set("http://localhost:8081", forKey: "serveraddress")
            serverAddress = NSURL(string: "http://localhost:8081")
        }
    }
    
    func getServerAddress() -> NSURL {
        return serverAddress!
    }
}
