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
    var sharedNotes: [String]

    
    init(username: String, password: String, phone: String, email: String, passcode: String, sharedNotes: [String]) {
        self.username = username
        self.password = password
        self.phone = phone
        self.email = email
        self.passcode = passcode
        self.sharedNotes = sharedNotes
    }
    
    var dictionary: [String: Any] {
        return [
            "username": username,
            "password": password,
            "phone": phone,
            "email": email,
            "passcode": passcode,
            "sharedNotes": sharedNotes
        ]
    }
}


