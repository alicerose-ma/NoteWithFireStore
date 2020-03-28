//
//  SignUpViewController.swift
//  note
//
//  Created by Ma Alice on 1/7/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, Alertable {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        customUI()
        usernameTextField.text = ""
        passwordTextField.text = ""
        confirmPassTextField.text = ""
        errorLabel.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }


    @IBAction func signUpAction(_ sender: Any) {
        let usernameText = usernameTextField.text!
        let passwordText = passwordTextField.text!
        let confirmText = confirmPassTextField.text!
        let phoneText = phoneTextField.text!
        let emailText = emailTextField.text!

//        check if user input valid username & password
        let validInput: Bool = validUsernameAndPassWord(username: usernameText, password: passwordText, confirmPass: confirmText, phone: phoneText, email: emailText)

        if validInput {
            let newUser = UserData(username: usernameText, password: passwordText, phone: phoneText, email: emailText, passcode: "", sharedNotes: [])
            SignUpViewModel.shared.addNewUser(username: usernameText, newUser: newUser, completion: { message in
                self.errorLabel.text = message
                self.showResultCreateUserAlert(title: "Create new user", message: "Success")
            })
            self.errorLabel.isHidden = false
        }
}


//    validation for input username & password
    func validUsernameAndPassWord(username: String, password: String, confirmPass: String, phone: String, email: String) -> Bool{
        var errorMessage = ""
        var isValid = true
        let usernameLength = username.count

        if usernameLength < 3 {
            errorMessage.append("\nUsername > 3 chars")
        }

        if password != confirmPass {
            errorMessage.append("\npassword and confirm do not match")
        }

        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\nusername can not empty")
        }

        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\npassword can not empty")
        }

        if phone.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\nphone can not empty")
        }

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage.append("\nemail can not empty")
        }


        if errorMessage != "" {
            print(errorMessage)
            errorLabel.text = errorMessage
            errorLabel.isHidden = false
            isValid = false
        }

        return isValid
    }

//  custom UI
    func customUI(){
        let uiTextFieldList: [UITextField: String] = [usernameTextField : "Username" ,
                                                      passwordTextField : "Password",
                                                      confirmPassTextField: "Confirm password",
                                                      phoneTextField: "Phone Number",
                                                      emailTextField: "Email"
        ]
        for (textField, placeHolder) in uiTextFieldList {
            customTextField(textField, placeHolder)
        }

        customButton(signUpButton)
    }

    let customTextField: (UITextField, String) -> Void = { (textField, placeHolder) in
        textField.attributedPlaceholder = NSAttributedString(string: "  \(placeHolder)",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        textField.layer.cornerRadius = 18
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.clipsToBounds = true
    }

    let customButton: (UIButton) -> Void = { (button) in
        button.layer.cornerRadius = 18
    }

}
