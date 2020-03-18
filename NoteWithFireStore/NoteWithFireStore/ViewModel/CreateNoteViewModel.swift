//
//  CreateNoteVIewModel.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.


import Foundation
import UIKit

class CreateNoteViewModel {
    let username = UserDefaults.standard.string(forKey: "username")
    var micStart = UIButton(type: .custom)
    var isHidden = true
    
    public func addNewNote(documentID: String, newNote: NoteData) {
        FireBaseProxy.shared.addNewNote(documentID: documentID, newNote: newNote)
    }
    
    public func createUniqueNoteDocID(username: String, uniqueID: Int) -> String {
        return username + "note" + String(uniqueID)
    }
    
    
    func displayPasscode(alert: UIAlertController){
        if isHidden {
            alert.textFields?.first?.isSecureTextEntry = false
            isHidden = false
            setPasscodeIcon(name: "eye.slash", textField: (alert.textFields?.first)!)
        } else {
            alert.textFields?.first?.isSecureTextEntry = true
            isHidden = true
            setPasscodeIcon(name: "eye", textField: (alert.textFields?.first)!)
        }
    }
    
    func setPasscodeIcon(name: String, textField: UITextField) {
        self.micStart.setImage(UIImage(systemName: name), for: .normal)
        self.micStart.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        self.micStart.frame = CGRect(x: CGFloat(textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
    }
    
}

