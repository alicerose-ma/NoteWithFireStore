//
//  KeyboardHelper.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/28/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit

class KeyboardHelper {
    static let shared = KeyboardHelper()
    private init() {}
    
    func dismissKeyboard(viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: viewController.view, action: #selector(UIView.endEditing(_:)))
        viewController.view.addGestureRecognizer(tap)
    }
}
