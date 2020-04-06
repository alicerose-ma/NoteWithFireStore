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
    var email: String
    var password: String
    var phone: String
    var displayName: String
    var passcode: String
    var hint: String
    var sharedNotes: [String]

    
//    dicitonary to add to fire store
    var dictionary: [String: Any] {
        return [
            "email": email,
            "password": password,
            "phone": phone,
            "displayName": email,
            "passcode": passcode,
            "sharedNotes": sharedNotes,
            "hint": hint,
        ]
    }
}


