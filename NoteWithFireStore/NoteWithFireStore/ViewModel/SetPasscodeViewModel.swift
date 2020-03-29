//
//  SetPasswordViewModel.swift
//  note
//
//  Created by Ma Alice on 2/15/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

public class SetPasscodeViewModel {
    static let shared =  SetPasscodeViewModel()
    private init() {}
    
    var username: String? = NoteViewModel.shared.username
    
//    get and update passcode 
    public func updateUserPasscode(passcode: String, hint: String){
        FireBaseProxy.shared.updateUserPasscode(username: username!, passcode: passcode, hint: hint, completion: { _ in
        })
    }
    
    public func getUserPasscode(completion: @escaping (String, String) -> Void){
        FireBaseProxy.shared.getUserPasscode(username: username!, completion: { passcode,hint  in
            completion(passcode, hint)
        })
    }
    
    
    //    validate passcode
    public func isPasscodeEmpty(completion: @escaping (Bool) -> Void){
        FireBaseProxy.shared.getUserPasscode(username: username!, completion: { (passcode, hint)  in
            if passcode == "" {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    public func confirmPasscode(passcode: String, confirmCode: String) -> Bool {
        if passcode == confirmCode {
            return true
        } else {
            return false
        }
    }
    
    
    
    
    
    
    
}
