//
//  SetPasswordViewController.swift
//  note
//
//  Created by Ma Alice on 2/15/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

protocol SetPasscodeDelegate {
    func addLockIconToNavBar()
}

class SetPasscodeViewController: UIViewController, Alertable {
    
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var confirmPasscode: UITextField!
    var setPasscodeDelegate: SetPasscodeDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        load passcode
        SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
            if passcode != "" {
                self.passcodeTextField.text = passcode
                self.confirmPasscode.text = passcode
            }
        })
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let setPasscodeBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(setPasscode))
        navigationItem.rightBarButtonItem = setPasscodeBtn
    }
    
    
    //    update passcode to firestore
    @objc func setPasscode() {
        if passcodeTextField!.text == "" {
            showStoredPasscodeAlert(goBackPreviousView: false,title: .passcodeSetup, message: .emptyPasscode)
        } else {
            let validPasscode = SetPasscodeViewModel.shared.confirmPasscode(passcode: passcodeTextField.text!, confirmCode: confirmPasscode.text!)
            
            if validPasscode {
                SetPasscodeViewModel.shared.isPasscodeEmpty(completion: { isPasscodeEmpty in
                    if isPasscodeEmpty {
                        self.setPasscodeDelegate.self?.addLockIconToNavBar()
                        self.showStoredPasscodeAlert(goBackPreviousView: true,title: .passcodeSetup, message: .storePasscode)
                    } else {
                        self.showStoredPasscodeAlert(goBackPreviousView: true,title: .passcodeSetup, message: .updatePasscode)
                    }
                    SetPasscodeViewModel.shared.updateUserPasscode(passcode: self.passcodeTextField.text!)
                })
            } else {
                showStoredPasscodeAlert(goBackPreviousView: false,title: .passcodeSetup, message: .invalidConfirm)
            }
        }
    }
}
