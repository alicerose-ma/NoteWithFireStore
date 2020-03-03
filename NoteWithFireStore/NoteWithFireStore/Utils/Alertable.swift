//
//  Alertable.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 2/24/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit


//validate passcode to lock
public enum PasscodeValidationError: String {
    case wrong = "Wrong Passcode"
}

//set up passcode
public enum PasscodeMessage: String {
    case storePasscode =  "Passcode successfully stored"
    case updatePasscode = "Passcode successfully updated"
    case emptyPasscode = "Passcode can not empty"
    case invalidConfirm = "Passcode and confirm passcode does not match"
}

public enum alertTitle: String {
    case passcodeSetup = "Passcode Setup"
    case passcodeValidation = "Passcode Validation"
}

public protocol Alertable {}

public extension Alertable where Self: UIViewController {
    
    func showAlert(title: alertTitle, message: PasscodeValidationError, preferredStyle: UIAlertController.Style = .alert, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
    func showStoredPasscodeAlert(goBackPreviousView: Bool, title: alertTitle, message: PasscodeMessage) {
        let alert = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: UIAlertController.Style.alert)

         alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            if goBackPreviousView {
                self.navigationController?.popViewController(animated: true)
            }
         }
         ))
         self.present(alert, animated: true, completion: nil)
    }

    

}

