//
//  LoginViewModel.swift
//  note
//
//  Created by Ma Alice on 1/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import Firebase

public class LoginViewModel {
    static let shared = LoginViewModel()
    private init() {}
    
    //    check input username & password vs firebase
    public func checkLogin(username: String, password: String, completion: @escaping (Bool) -> Void) {
        FireBaseProxy.shared.sendUserRequest(username: username, completion: { users in
            if users.count == 0 {
                completion(false)
            } else {
                for user in users {
                    if user.username == username && user.password == password {
                        completion(true)
                        break
                    } else {
                        completion(false)
                        break
                    }
                }
            }
        })
    }
    
    
}



