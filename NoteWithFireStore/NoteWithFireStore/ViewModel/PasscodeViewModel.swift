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
    
    var textField = UITextField()
    var hiddenPwdIcon = UIButton(type: .custom)
    var isHidden = false
    
    //    MARK: - PASSWORD ICON SHOW
    //    setup password show or hide
    func setupPasswordIcon(color: UIColor) {
        isHidden = false
        if #available(iOS 13.0, *) {
            hiddenPwdIcon.setImage(UIImage(systemName: "eye")!.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            hiddenPwdIcon.setImage(UIImage(named: "eye")!.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        hiddenPwdIcon.tintColor = color
        hiddenPwdIcon.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        hiddenPwdIcon.frame = CGRect(x: CGFloat(textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        
        hiddenPwdIcon.addTarget(self, action: #selector(showAndHidePasscodeAction), for: .touchUpInside)
        textField.rightView = hiddenPwdIcon
        textField.rightViewMode = .always
    }
    
    @objc func showAndHidePasscodeAction(_ sender: Any) {
        if isHidden {
            textField.isSecureTextEntry = false
            if #available(iOS 13.0, *) {
                hiddenPwdIcon.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            } else {
                hiddenPwdIcon.setImage(UIImage(named: "eyeSlash"), for: .normal)
            }
        } else {
            textField.isSecureTextEntry = true
            if #available(iOS 13.0, *) {
                hiddenPwdIcon.setImage(UIImage(systemName: "eye"), for: .normal)
            } else {
                hiddenPwdIcon.setImage(UIImage(named: "eye"), for: .normal)
            }
        }
        
        hiddenPwdIcon.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        hiddenPwdIcon.frame = CGRect(x: CGFloat(textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        isHidden = !isHidden
    }
    
}
