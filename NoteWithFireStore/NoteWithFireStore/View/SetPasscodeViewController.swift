//
//  SetPasswordViewController.swift
//  note
//
//  Created by Ma Alice on 2/15/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

protocol SetPasscodeDelegate {
    func addLockStatus()
}

class SetPasscodeViewController: UIViewController, Alertable {

    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var confirmPasscode: UITextField!
    var setPasscodeViewModel = SetPasscodeViewModel()
    var setPasscodeDelegate: SetPasscodeDelegate?
    
    var passcode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if passcode != nil {
           passcodeTextField.text = passcode
           confirmPasscode.text = passcode
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
         let setPasscodeBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(setPasscode))
         navigationItem.rightBarButtonItem = setPasscodeBtn
    }
    
    @objc func setPasscode() {
        if passcodeTextField!.text == "" {
            showStoredPasscodeAlert(goBackPreviousView: false,title: .passcodeSetup, message: .emptyPasscode)
        } else {
            let validPasscode = setPasscodeViewModel.confirmPasscode(passcode: passcodeTextField.text!, confirmCode: confirmPasscode.text!)
                
            if validPasscode {
                setPasscodeViewModel.storePasscode(passcode: passcodeTextField!.text!)
                if passcode == nil {
                    setPasscodeDelegate.self?.addLockStatus()
                    showStoredPasscodeAlert(goBackPreviousView: true,title: .passcodeSetup, message: .storePasscode)
                } else {
                    showStoredPasscodeAlert(goBackPreviousView: true,title: .passcodeSetup, message: .updatePasscode)
                }
            } else {
                showStoredPasscodeAlert(goBackPreviousView: false,title: .passcodeSetup, message: .invalidConfirm)
            }
        }
    }
}
