//
//  SignUpViewModel.swift
//  note
//
//  Created by Ma Alice on 1/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

public class SignUpViewModel {
    static let shared = SignUpViewModel()
    private init() {}
    
    //    check if username does not in firebase yet => add new user
    func addNewUser(username: String, newUser: UserData, completion: @escaping (Bool, String) -> Void){
        FireBaseProxy.shared.isNewUsernameValid(username: username, completion: { isValid in
            if !isValid {
                completion(false,"username exists")
            } else {
                FireBaseProxy.shared.addNewUser(username: username, newUser: newUser, completion: { (isSuccess, message) in
                    completion(isSuccess, message)
                })
            }
        })
    }
    
    
    //    validation for input username & password
    func validUsernameAndPassWord(username: String, password: String, confirmPass: String, phone: String, email: String) -> (Bool,String){
        var errorMessage = ""
        var isValid = true
        let usernameLength = username.count
        
        if usernameLength < 3 {
            errorMessage.append("\nUsername > 3 chars")
        }
        
        if password != confirmPass {
            errorMessage.append("\npassword and confirm do not match")
        }
        
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\nusername can not empty")
        }
        
        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\npassword can not empty")
        }
        
        if errorMessage != "" {
            isValid = false
        }
        
        return (isValid, errorMessage)
    }
}
