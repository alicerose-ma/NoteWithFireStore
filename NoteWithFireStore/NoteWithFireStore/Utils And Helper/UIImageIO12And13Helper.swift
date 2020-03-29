//
//  LockNoteViewModel.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/29/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit

class UIImageIO12And13Helper {
    static let shared = UIImageIO12And13Helper()
    private init() {}
    
    func createBarButtonItem(name: String, action: Selector)  -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: name), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }
}
