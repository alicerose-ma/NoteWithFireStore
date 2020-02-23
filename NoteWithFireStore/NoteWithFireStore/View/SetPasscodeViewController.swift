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

class SetPasscodeViewController: UIViewController {

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
            self.showPasscodeAlert(goBackPreviousView: false, message: "passcode can not empty")
        } else {
            let validPasscode = setPasscodeViewModel.confirmPasscode(passcode: passcodeTextField.text!, confirmCode: confirmPasscode.text!)
                
            if validPasscode {
                setPasscodeDelegate.self?.addLockStatus()
                setPasscodeViewModel.storePasscode(passcode: passcodeTextField!.text!)
                self.showPasscodeAlert(goBackPreviousView: true, message: "stored passcode")
            } else {
                self.showPasscodeAlert(goBackPreviousView: false, message: "passcode does not match")
            }
        }
    }
    
    func showPasscodeAlert(goBackPreviousView: Bool, message: String) {
         let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)

         alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            if goBackPreviousView {
                self.navigationController?.popViewController(animated: true)
            }
         }
         ))
         self.present(alert, animated: true, completion: nil)
    }

}
