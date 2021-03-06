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
    
    func login(email: String, password: String, completion: @escaping (Bool, String) -> Void){
        FireBaseProxy.shared.login(email: email, password: password, completion: { (isLogin, message) in
            if isLogin {
                completion(true, message)
            } else {
                completion(false, message)
            }
            
        })
    }
    
    //    update current username of app
    func updateCurrentUsername(newUsername: String) {
        let defaults = UserDefaults.standard
        defaults.set(newUsername, forKey: "username")
        let newUser =  UserDefaults.standard.string(forKey: "username") // change username
        NoteViewModel.shared.username = newUser
        NoteDetailViewModel.shared.username = newUser
        SetPasscodeViewModel.shared.username = newUser
        SharedNoteViewModel.shared.username = newUser
    }
}



