//
//  UserModel.swift
//  note
//
//  Created by Ma Alice on 1/7/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

// user data model in fire store
public struct UserData: Decodable {
    var username: String
    var password: String
    var phone: String
    var email: String
    var passcode: String
    var hint: String
    var sharedNotes: [String]

    
//    dicitonary to add to fire store
    var dictionary: [String: Any] {
        return [
            "username": username,
            "password": password,
            "phone": phone,
            "email": email,
            "passcode": passcode,
            "sharedNotes": sharedNotes,
            "hint": hint,
        ]
    }
}


