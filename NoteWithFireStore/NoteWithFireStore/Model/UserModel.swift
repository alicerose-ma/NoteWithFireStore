//
//  UserModel.swift
//  note
//
//  Created by Ma Alice on 1/7/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation


public struct UserData: Decodable {
    var username: String
    var password: String
    var phone: String
    var email: String
    var passcode: String
    
    init() {
        self.username = ""
        self.password = ""
        self.phone = ""
        self.email = ""
        self.passcode = ""
    }
    
    init(username: String, password: String, phone: String, email: String, passcode: String) {
        self.username = username
        self.password = password
        self.phone = phone
        self.email = email
        self.passcode = passcode
    }
    
    var dictionary: [String: Any] {
        return [
            "username": username,
            "password": password,
            "phone": phone,
            "email": email,
            "passcode": passcode
        ]
    }
}


