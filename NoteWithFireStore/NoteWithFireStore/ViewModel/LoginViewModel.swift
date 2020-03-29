//
//  LoginViewModel.swift
//  note
//
//  Created by Ma Alice on 1/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

public class LoginViewModel {
    static let shared = LoginViewModel()
    private init() {}
    
    //    check input username & password vs firebase
    public func checkLogin(username: String, password: String, completion: @escaping (Bool) -> Void) {
        FireBaseProxy.shared.sendUserRequest(username: username, password: password ,completion: { users in
            if users.count == 0 {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    //    update current username of app
    func updateCurrentUsername(newUsername: String) {
        let defaults = UserDefaults.standard
        defaults.set(newUsername, forKey: "username")
        let newUser =  UserDefaults.standard.string(forKey: "username") // change username
        NoteViewModel.shared.username = newUser
    }
}



