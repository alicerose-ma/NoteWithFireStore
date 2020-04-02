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
            errorMessage.append("\nusername needs > 3 chars")
        }
        
        if username.contains(" ") {
            errorMessage.append("\nusername can't contain space")
        }
        
        if usernameLength == 50 {
            errorMessage.append("\nusername can not > 50 chars")
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
        
        if !isValidEmail(email: email) && !email.isEmpty {
            errorMessage.append("\ninvalid email")
        }
        
        if errorMessage != "" {
            isValid = false
        }
        
        return (isValid, errorMessage)
    }
    
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
