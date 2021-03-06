//
//  ViewController.swift
//  note
//
//  Created by Ma Alice on 12/30/19.
//  Copyright © 2019 Ma Alice. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class LoginViewController: UIViewController, UITextFieldDelegate, Alertable {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        customUI()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
        PasscodeShowOrHideHelper.shared.textField = passwordTextField
        PasscodeShowOrHideHelper.shared.setupPasswordIcon(color: .white)
        didLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    //    MARK: - LOGIN
    @IBAction func loginAction(_ sender: UIButton ) {
        let emailText = emailTextField.text!
        let passwordText = passwordTextField.text!
        
        if(emailText.isEmpty == true || passwordText.isEmpty == true) {
            SCLAlertView().showNotice("", subTitle: "Enter username & password")
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                 showCloseButton: false
             )
             let alert = SCLAlertView(appearance: appearance).showWait("Verifying", subTitle: "", closeButtonTitle: nil, timeout: nil, colorStyle: nil, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: SCLAnimationStyle.topToBottom)
            LoginViewModel.shared.login(email: emailText, password: passwordText, completion: { (isLogin, message) in
                if isLogin{
                    LoginViewModel.shared.updateCurrentUsername(newUsername: emailText)
                    DispatchQueue.main.async {
                        alert.close()
                        self.performSegue(withIdentifier: "ShowNoteViewSegue", sender: self)
                    }
                } else {
                    DispatchQueue.main.async {
                        alert.close()
                        SCLAlertView().showError("Login Fail", subTitle: message, closeButtonTitle: "OK")
                    }
                }
            })
        }
        self.view.endEditing(true)
    }
    
    @IBAction func resetPassword(_ sender: Any) {
         let appearance = SCLAlertView.SCLAppearance(
                 kTextFieldHeight: 60,
                 showCloseButton: true
        )
        if #available(iOS 13.0, *) {
            let alert = SCLAlertView(appearance: appearance)
            let txt = alert.addTextField("Enter your email")
            alert.addButton("Reset Password") {
                let resetEmail = txt.text
                FireBaseProxy.shared.resetPassword(resetEmail: resetEmail!, completion: { (isSuccess, message) in
                    if isSuccess {
                        SCLAlertView().showSuccess("Reset email sent successfully", subTitle: message, closeButtonTitle: "OK")
                    } else {
                        SCLAlertView().showError("Reset Failed", subTitle: message, closeButtonTitle: "OK")
                    }
                })
            }
            alert.showInfo("Forget password", subTitle: "Enter email address", closeButtonTitle: "Cancel")
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func didLogin(){
        FireBaseProxy.shared.didLogin(completion: { (didLogin, email) in
            if didLogin {
                LoginViewModel.shared.updateCurrentUsername(newUsername: email)
                UIView.setAnimationsEnabled(false)
                self.performSegue(withIdentifier: "ShowNoteViewSegue", sender: self)
            }
        })
    }
    //    MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNoteViewSegue" {
        }
    }
}


extension LoginViewController {
    //    MARK: - KEYBOARD AND STATUS BAR
    //    hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //    hide keyboard when click return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //    limit input textfield chars
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 50
    }
    
    
    //    MARK: - SET UP UI AND DELEGATE
    //    set up UI
    func setupUI() {
        emailTextField.text = ""
        passwordTextField.text = ""
        passwordTextField.isSecureTextEntry = true
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //    setup delegate
    func setupDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //    MARK: - CUSTOM UI
    //    custom button & text field UI
    func customUI(){
        let uiTextFieldList: [UITextField: String] = [emailTextField : "Email" ,
                                                      passwordTextField : "Password"]
        for (textField, placeHolder) in uiTextFieldList {
            TextFieldAndButtonCustomUI.shared.customTextField(textField, placeHolder)
            TextFieldAndButtonCustomUI.shared.customPaddingForTextField(textField)
        }
        TextFieldAndButtonCustomUI.shared.customButton(loginButton)
    }
}




