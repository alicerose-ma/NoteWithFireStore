//
//  SignUpViewModel.swift
//  note
//
//  Created by Ma Alice on 1/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

class SignUpViewModel {

//    check if username does not in firebase yet => add new user
func addNewUser(username: String, newUser: UserData, completion: @escaping (String) -> Void){
       FireBaseProxy.shared.isNewUsernameValid(username: username, completion: { isValid in
           if !isValid {
               completion("username exists")
           } else {
               FireBaseProxy.shared.addNewUser(username: username, newUser: newUser, completion: { message in
                   print(message)
                   completion(message)
               })
           }
       })
   }
}
