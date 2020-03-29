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

class SetPasscodeViewController: UIViewController, UITextFieldDelegate, Alertable {
    
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var confirmPasscode: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    var setPasscodeDelegate: SetPasscodeDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBarAndDelegate()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
    }
    
    func setupNavBarAndDelegate(){
        let setPasscodeBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(setPasscode))
        navigationItem.rightBarButtonItem = setPasscodeBtn
        passcodeTextField.delegate = self
        confirmPasscode.delegate = self
        hintTextField.delegate = self
        passcodeTextField.placeholder = "Passcode"
        confirmPasscode.placeholder = "Confirm passcode"
        hintTextField.placeholder = "Recommended"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCurrentPasscode()
        SetPasscodeViewModel.shared.isDelegate = false
    }
    
    //   load passcode
    func loadCurrentPasscode() {
        SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint) in
            if passcode != "" {
                self.passcodeTextField.text = passcode
                self.confirmPasscode.text = passcode
                self.hintTextField.text = hint
            }
        })
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
                    SetPasscodeViewModel.shared.updateUserPasscode(passcode: self.passcodeTextField.text!, hint: self.hintTextField.text!)
                })
            } else {
                showStoredPasscodeAlert(goBackPreviousView: false,title: .passcodeSetup, message: .invalidConfirm)
            }
        }
    }
}
