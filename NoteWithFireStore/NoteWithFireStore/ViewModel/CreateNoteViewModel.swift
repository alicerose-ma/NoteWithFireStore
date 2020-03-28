//
//  CreateNoteVIewModel.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.


import Foundation
import UIKit

public class CreateNoteViewModel {
    static let shared =  CreateNoteViewModel()
    private init() {}
    
    var username: String? = UserDefaults.standard.string(forKey: "username")
    var hiddenPwdIcon = UIButton(type: .custom)
    var isHidden = false
    
    public func addNewNote(documentID: String, newNote: NoteData) {
        FireBaseProxy.shared.addNewNote(documentID: documentID, newNote: newNote)
    }
    
    public func createUniqueNoteDocID(username: String, uniqueID: Int) -> String {
        return username + "note" + String(uniqueID)
    }
    
    
}

