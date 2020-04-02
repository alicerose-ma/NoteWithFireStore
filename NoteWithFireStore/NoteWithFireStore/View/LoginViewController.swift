//
//  ViewController.swift
//  note
//
//  Created by Ma Alice on 12/30/19.
//  Copyright © 2019 Ma Alice. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, Alertable {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        customUI()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
        ShowPasscodeViewModel.shared.textField = passwordTextField
        ShowPasscodeViewModel.shared.setupPasswordIcon(color: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    hide keyboard when click return
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
    
    //    MARK: - LOGIN
    @IBAction func loginAction(_ sender: UIButton ) {
        let usernameText = usernameTextField.text!
        let passwordText = passwordTextField.text!
        
        if(usernameText.isEmpty == true || passwordText.isEmpty == true) {
            self.loginStatus.text = "Enter username & password"
        } else {
            waitAlert()
            LoginViewModel.shared.checkLogin(username: usernameText, password: passwordText, completion: { success in
                print(success)
                if success {
                    self.loginStatus.text = "Successed"
                    LoginViewModel.shared.updateCurrentUsername(newUsername: self.usernameTextField.text!)
                    self.dismiss(animated: false, completion: {
                        self.performSegue(withIdentifier: "ShowNoteViewSegue", sender: self)
                    })
                } else {
                    self.dismiss(animated: false, completion: nil)
                    self.loginStatus.text = "Failed"
                }
            })
        }
        self.loginStatus.isHidden = false
        self.view.endEditing(true)
    }
    
    //    MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNoteViewSegue" {
            //            let nav = segue.destination as! UINavigationController
            //            nav.modalPresentationStyle = .fullScreen
        }
    }
    
    
    //    MARK: - SET UP UI AND DELEGATE
    //    set up UI
    func setupUI() {
        usernameTextField.text = ""
        passwordTextField.text = ""
        loginStatus.isHidden = true
        passwordTextField.isSecureTextEntry = true
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //    setup delegate
    func setupDelegate() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    //    MARK: - CUSTOM UI
    //    custom button & text field UI
    func customUI(){
        let uiTextFieldList: [UITextField: String] = [usernameTextField : "Username" ,
                                                      passwordTextField : "Password"]
        for (textField, placeHolder) in uiTextFieldList {
            TextFieldAndButtonCustomUI.shared.customTextField(textField, placeHolder)
            TextFieldAndButtonCustomUI.shared.customPaddingForTextField(textField)
        }
        TextFieldAndButtonCustomUI.shared.customButton(loginButton)
    }
}







