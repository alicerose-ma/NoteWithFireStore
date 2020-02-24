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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let setPasscodeBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(setPasscode))
        navigationItem.rightBarButtonItem = setPasscodeBtn
    }
    
    @objc func setPasscode() {
        if passcodeTextField!.text == "" {
            showStoredPasscodeAlert(goBackPreviousView: false,title: "Passcode", message: "passcode can not empty")
        } else {
            let validPasscode = setPasscodeViewModel.confirmPasscode(passcode: passcodeTextField.text!, confirmCode: confirmPasscode.text!)
                
            if validPasscode {
                setPasscodeDelegate.self?.addLockStatus()
                setPasscodeViewModel.storePasscode(passcode: passcodeTextField!.text!)
                showStoredPasscodeAlert(goBackPreviousView: true,title: "Passcode", message: "passcode successful stored")
            } else {
                showStoredPasscodeAlert(goBackPreviousView: false,title: "Passcode", message: "passcode and confirm passcode does not match")
            }
        }
    }
}
