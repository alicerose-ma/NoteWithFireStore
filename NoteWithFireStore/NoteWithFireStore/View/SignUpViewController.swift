//
//  SignUpViewController.swift
//  note
//
//  Created by Ma Alice on 1/7/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, Alertable {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        customUI()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //    MARK: - SIGN UP
    @IBAction func signUpAction(_ sender: Any) {
        let usernameText = usernameTextField.text!
        let passwordText = passwordTextField.text!
        let confirmText = confirmPassTextField.text!
        let phoneText = phoneTextField.text!
        let emailText = emailTextField.text!
        
        //        check if user input valid username & password
        let validInput: (isValid: Bool, errorMessage: String) = SignUpViewModel.shared.validUsernameAndPassWord(username: usernameText, password: passwordText, confirmPass: confirmText, phone: phoneText, email: emailText)
        
        if validInput.isValid {
            waitAlert()
            let newUser = UserData(username: usernameText, password: passwordText, phone: phoneText, email: emailText, passcode: "", sharedNotes: [])
            SignUpViewModel.shared.addNewUser(username: usernameText, newUser: newUser, completion: { (isSuccess,message) in
                self.errorLabel.text = message
                self.dismiss(animated: false, completion: nil)
                if isSuccess {
                    self.showResultCreateUserAlert(title: "Create new user", message: "Success")
                }
            })
        } else {
            self.errorLabel.text = validInput.errorMessage
        }
        self.errorLabel.isHidden = false
    }
    
    
    //    MARK: - SET UP & CUSTOM UI
    func setupUI() {
        usernameTextField.text = ""
        passwordTextField.text = ""
        confirmPassTextField.text = ""
        errorLabel.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //    set up delegate
    func setupDelegate() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPassTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
    }
    
    //  custom UI
    func customUI(){
        let uiTextFieldList: [UITextField: String] = [usernameTextField : "Username" ,
                                                      passwordTextField : "Password",
                                                      confirmPassTextField: "Confirm password",
                                                      phoneTextField: "Phone Number (Optional)",
                                                      emailTextField: "Email (Optional)"
        ]
        for (textField, placeHolder) in uiTextFieldList {
            TextFieldAndButtonCustomUI.shared.customTextField(textField, placeHolder)
            TextFieldAndButtonCustomUI.shared.customPaddingForTextField(textField)
        }
        TextFieldAndButtonCustomUI.shared.customButton(signUpButton)
    }
}
