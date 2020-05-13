//
//  TextFieldAndButtonCustomUI.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/29/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

import UIKit

class TextFieldAndButtonCustomUI {
    static let shared = TextFieldAndButtonCustomUI()
    private init() {}
    
    let customPaddingForTextField: (UITextField) -> Void = { textField in
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    let customTextField: (UITextField, String) -> Void = { (textField, placeHolder) in
        textField.attributedPlaceholder = NSAttributedString(string: "\(placeHolder)",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        textField.layer.cornerRadius = 18
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.clipsToBounds = true
        textField.font = UIFont(name: "Baskerville", size:  14)
    }
    
    let customButton: (UIButton) -> Void = { (button) in
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
}
