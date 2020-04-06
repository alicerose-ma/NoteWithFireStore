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
    func addNewUserToDatabase(email: String, newUser: UserData, completion: @escaping (Bool, String) -> Void){
        FireBaseProxy.shared.addNewUserToDatabase(email: email, newUser: newUser, completion: { (isSuccess, message) in
            completion(isSuccess, message)
        })
    }
    
    func signUpUser(email: String, password: String, displayName: String, completion: @escaping (Bool) -> Void) {
        FireBaseProxy.shared.signup(email: email, password: password, displayName: displayName, completion: { isSignUp in
            if isSignUp {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
   
    
    //    validation for input username & password
    func validUsernameAndPassWord(email: String, password: String, confirmPass: String, displayName: String, phone: String) -> (Bool,String){
        var errorMessage = ""
        var isValid = true
        let emailLength = email.count
        let passwordLength = password.count
        
        if !isValidEmail(email: email) {
            errorMessage.append("\ninvalid email")
        }
        
        if emailLength == 50 {
            errorMessage.append("\nemail can not > 50 chars")
        }
        
        if passwordLength < 6 {
            errorMessage.append("\npassword needs at least 6 chars")
        }
        
        if password != confirmPass {
            errorMessage.append("\npassword and confirm do not match")
        }
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\nusername can not empty")
        }
        
        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\npassword can not empty")
        }
        
        if displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\nyour name can not empty")
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
