//
//  SignUpViewController.swift
//  note
//
//  Created by Ma Alice on 1/7/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit
import SCLAlertView

class SignUpViewController: UIViewController, UITextFieldDelegate, Alertable {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        customUI()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    
    //    MARK: - SIGN UP
    @IBAction func signUpAction(_ sender: Any) {
        let emailText = emailTextField.text!
        let passwordText = passwordTextField.text!
        let confirmText = confirmPassTextField.text!
        let displayNameText = displayNameTextField.text!
        let phoneText = phoneTextField.text!
        
        //check if user input valid username & password
        let validInput: (isValid: Bool, errorMessage: String) = SignUpViewModel.shared.validUsernameAndPassWord(email: emailText,password: passwordText, confirmPass: confirmText, displayName: displayNameText, phone: phoneText)
        
        if validInput.isValid {
            createNewAuthAndDatabaseAccount(emailText: emailText, passwordText: passwordText, displayNameText: displayNameText, phoneText: phoneText)
        } else {
            self.errorLabel.text = validInput.errorMessage
        }
        self.view.endEditing(true)
        self.errorLabel.isHidden = false
    }
    
    //  craete new auth account and firestore account
    func createNewAuthAndDatabaseAccount(emailText: String, passwordText: String, displayNameText: String, phoneText: String) {
       let appearance = SCLAlertView.SCLAppearance(
           showCloseButton: false
       )
       let alert = SCLAlertView(appearance: appearance).showWait("Creating", subTitle: "", closeButtonTitle: nil, timeout: nil, colorStyle: nil, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
        SignUpViewModel.shared.signUpUser(email: emailText, password: passwordText, displayName: displayNameText, completion: { (isSignUp, message)  in
            if isSignUp {
                //  sign up succes  => create user in database
                let newUser = UserData(email: emailText, phone: phoneText, displayName: displayNameText, passcode: "", hint: "", sharedNotes: [])
                SignUpViewModel.shared.addNewUserToDatabase(email: emailText, newUser: newUser, completion: { (isSuccess,message) in
                    DispatchQueue.main.async {
                        self.errorLabel.text = message
                        if isSuccess {
                            DispatchQueue.main.async() {
                                alert.close()
                                SCLAlertView().showSuccess("Create new user", subTitle: "Success, please verify email to login", closeButtonTitle: "OK")
                            }
                        } else {
                            alert.close()
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    alert.close()

                        self.errorLabel.text = message
                }
            }
        })
    }
    
}


extension SignUpViewController{
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 50
    }
    
    //    MARK: - SET UP & CUSTOM UI
    func setupUI() {
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPassTextField.text = ""
        displayNameTextField.text = ""
        phoneTextField.text = ""
        errorLabel.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    //    set up delegate
    func setupDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPassTextField.delegate = self
        displayNameTextField.delegate = self
        phoneTextField.delegate = self
        phoneTextField.keyboardType = .asciiCapableNumberPad
    }
    
    //  custom UI
    func customUI(){
        let uiTextFieldList: [UITextField: String] = [emailTextField : "Email" ,
                                                      passwordTextField : "Password",
                                                      confirmPassTextField: "Confirm password",
                                                      displayNameTextField: "Your Name",
                                                      phoneTextField: "Phone Number (Optional)"
        ]
        for (textField, placeHolder) in uiTextFieldList {
            TextFieldAndButtonCustomUI.shared.customTextField(textField, placeHolder)
            TextFieldAndButtonCustomUI.shared.customPaddingForTextField(textField)
        }
        TextFieldAndButtonCustomUI.shared.customButton(signUpButton)
    }
}



