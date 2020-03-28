//
//  ViewController.swift
//  note
//
//  Created by Ma Alice on 12/30/19.
//  Copyright © 2019 Ma Alice. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
//    var isHidden = true
//    var hiddenPwdIcon = UIButton(type: .custom)
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PasscodeViewModel.shared.setPasscodeIcon(name: "eye", textField: passwordTextField)
        PasscodeViewModel.shared.hiddenPwdIcon.addTarget(self, action: #selector(self.showAndHidePasscodeAction), for: .touchUpInside)
        passwordTextField.rightView = PasscodeViewModel.shared.hiddenPwdIcon
        passwordTextField.rightViewMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customUI()
        usernameTextField.text = ""
        passwordTextField.text = ""
        loginStatus.isHidden = true

        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func loginAction(_ sender: UIButton ) {
        let usernameText = usernameTextField.text!
        let passwordText = passwordTextField.text!
        
        if(usernameText.isEmpty == true || passwordText.isEmpty == true) {
            self.loginStatus.text = "Enter username & password"
        } else {
            LoginViewModel.shared.checkLogin(username: usernameText, password: passwordText, completion: { success in
                print(success)
                if success {
                    self.loginStatus.text = "Success"
                    let defaults = UserDefaults.standard
                    defaults.set(usernameText, forKey: "username")
                    let newUser =  UserDefaults.standard.string(forKey: "username") // change username
                    NoteViewModel.shared.username = newUser
                    NoteDetailViewModel.shared.username = newUser
                    CreateNoteViewModel.shared.username = newUser
                    SetPasscodeViewModel.shared.username = newUser
                    SharedNoteViewModel.shared.username = newUser
                    PasscodeViewModel.shared.isHidden = false
                    self.performSegue(withIdentifier: "ShowNoteViewSegue", sender: self)
                } else {
                     self.loginStatus.text = "Failed"
                }
            })
        }
        self.loginStatus.isHidden = false
    }
    
//    transfer to main note list view by Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNoteViewSegue" {
//            let nav = segue.destination as! UINavigationController
//            nav.modalPresentationStyle = .fullScreen
        }
    }
    
    //    custom UI view
    func customUI(){
        let uiTextFieldList: [UITextField: String] = [usernameTextField : "Username" ,
                                                      passwordTextField : "Password"]
        for (textField, placeHolder) in uiTextFieldList {
            customTextField(textField, placeHolder)
        }
        customButton(loginButton)
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
    
    
    
    @objc func showAndHidePasscodeAction(_ sender: Any) {
        PasscodeViewModel.shared.displayPasscode(textField: passwordTextField)
    }
       
}







