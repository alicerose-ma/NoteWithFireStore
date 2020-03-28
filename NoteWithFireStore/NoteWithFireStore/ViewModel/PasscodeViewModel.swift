//
//  LockPasscodeViewModel.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/27/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit

public class PasscodeViewModel {
    static let shared =  PasscodeViewModel()
    private init() {}
    var hiddenPwdIcon = UIButton(type: .custom)
    var isHidden = false
    
    
    //    show or hidden passcode input
    func displayPasscode(textField: UITextField){
        if isHidden {
            textField.isSecureTextEntry = false
            if #available(iOS 13.0, *) {
                hiddenPwdIcon.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            } else {
                hiddenPwdIcon.setImage(UIImage(named: "eyeSlash"), for: .normal)
            }
            hiddenPwdIcon.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            hiddenPwdIcon.frame = CGRect(x: CGFloat(textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        } else {
            textField.isSecureTextEntry = true
            setPasscodeIcon(name: "eye", textField: textField)
        }
        isHidden = !isHidden
    }
    
    
    func setPasscodeIcon(name: String, textField: UITextField) {
        if #available(iOS 13.0, *) {
            hiddenPwdIcon.setImage(UIImage(systemName: name), for: .normal)
        } else {
            hiddenPwdIcon.setImage(UIImage(named: name), for: .normal)
        }
        hiddenPwdIcon.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16 , bottom: 0, right: 0)
        hiddenPwdIcon.frame = CGRect(x: CGFloat((textField.frame.size.width) - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
    }
    
}
