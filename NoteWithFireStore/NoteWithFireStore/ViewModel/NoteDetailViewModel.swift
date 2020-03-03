//
//  AddNewNoteViewModel.swift
//  note
//
//  Created by Ma Alice on 1/23/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

class NoteDetailViewModel {
    let username = UserDefaults.standard.string(forKey: "username")
    
//    edit note base on document ID
    public func editNote(uniqueID: Int, newNote: NoteData) {
        let documentID = username! + "note" + String(uniqueID)
        FireBaseProxy.shared.editNote(documentID: documentID, newNote: newNote)
    }
    
    public func getNoteByID(id: Int, completion: @escaping (([NoteData]) -> Void)) {
        FireBaseProxy.shared.getNoteByID(username: username!, id: id, completion: { notes in
            completion(notes)
        })
    }

    public func getUserPasscode(completion: @escaping (String) -> Void){
        FireBaseProxy.shared.getUserPasscode(username: username!, completion: { passcode in
            completion(passcode)
        })
    }
    
}
