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
    
    let username = UserDefaults.standard.string(forKey: "username")
    
    public func updateUserPasscode(passcode: String){
        FireBaseProxy.shared.updateUserPasscode(username: username!, passcode: passcode, completion: { _ in
        })
    }
    
    public func confirmPasscode(passcode: String, confirmCode: String) -> Bool {
        if passcode == confirmCode {
            return true
        } else {
            return false
        }
    }
    
    public func getUserPasscode(completion: @escaping (String) -> Void){
        FireBaseProxy.shared.getUserPasscode(username: username!, completion: { passcode in
            completion(passcode)
        })
    }
    
    public func isPasscodeEmpty(completion: @escaping (Bool) -> Void){
          FireBaseProxy.shared.getUserPasscode(username: username!, completion: { passcode in
            if passcode == "" {
                completion(true)
            } else {
                completion(false)
            }
          })
      }
    
    
    
    
    
    
  
}
