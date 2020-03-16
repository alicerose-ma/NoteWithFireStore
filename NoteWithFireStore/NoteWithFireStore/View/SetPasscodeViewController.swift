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
    var setPasscodeViewModel = SetPasscodeViewModel()
    var setPasscodeDelegate: SetPasscodeDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        load passcode
        setPasscodeViewModel.getUserPasscode(completion: { passcode in
            if passcode != "" {
                self.passcodeTextField.text = passcode
                self.confirmPasscode.text = passcode
            }
        })

        let micStart = UIButton(type: .custom)
        micStart.setImage(UIImage(systemName: "mic"), for: .normal)
        micStart.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        micStart.frame = CGRect(x: CGFloat(passcodeTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        micStart.addTarget(self, action: #selector(self.recordPasscodeStart), for: .touchUpInside)

        passcodeTextField.rightView = micStart
        passcodeTextField.rightViewMode = .always
//
//        confirmPasscode.rightView = micStart
//        confirmPasscode.rightViewMode = .unlessEditing
    }
    
    @objc func recordPasscodeStart(_ sender: Any) {
        showAlertWithInputStringForPasscode(title: "Passcode", textField: passcodeTextField)
//         voiceViewModel.startRecordingForPasscode(textField: (passcodeTextField!)
         passcodeTextField.rightView = nil
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
            let validPasscode = setPasscodeViewModel.confirmPasscode(passcode: passcodeTextField.text!, confirmCode: confirmPasscode.text!)
                
            if validPasscode {
                setPasscodeViewModel.isPasscodeEmpty(completion: { isPasscodeEmpty in
                    if isPasscodeEmpty {
                        self.setPasscodeDelegate.self?.addLockIconToNavBar()
                        self.showStoredPasscodeAlert(goBackPreviousView: true,title: .passcodeSetup, message: .storePasscode)
                    } else {
                        self.showStoredPasscodeAlert(goBackPreviousView: true,title: .passcodeSetup, message: .updatePasscode)
                    }
                    self.setPasscodeViewModel.updateUserPasscode(passcode: self.passcodeTextField.text!)
                    })
                } else {
                showStoredPasscodeAlert(goBackPreviousView: false,title: .passcodeSetup, message: .invalidConfirm)
            }
        }
    }
}
