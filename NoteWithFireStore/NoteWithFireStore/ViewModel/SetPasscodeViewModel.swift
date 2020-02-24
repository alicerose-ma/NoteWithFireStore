//
//  SetPasswordViewModel.swift
//  note
//
//  Created by Ma Alice on 2/15/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

class SetPasscodeViewModel {
    let username = UserDefaults.standard.string(forKey: "username")
    
    public func storePasscode(passcode: String) {
        let defaults = UserDefaults.standard
        defaults.set(passcode, forKey: username!)
    }
    
    public func confirmPasscode(passcode: String, confirmCode: String) -> Bool {
        if passcode == confirmCode {
            return true
        } else {
            return false
        }
    }
    
    
  
}
