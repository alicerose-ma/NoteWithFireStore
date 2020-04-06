//
//  NoteViewModel.swift
//  note
//
//  Created by Ma Alice on 1/20/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

public class NoteViewModel {
    static let shared =  NoteViewModel()
    private init() {}
    
    var username: String? = UserDefaults.standard.string(forKey: "username")
    var enterPasscodeCount = 0;
    
//  get all notes based on username
    public func getNoteList(email: String,completion: @escaping ([NoteData]) -> Void) {
        FireBaseProxy.shared.getNoteList(email: email, completion: { notes in
            completion(notes)
        })
    }
    
    
//    new id = max id value in note list + 1, no note => id = 0
    public func createNewUniqueNoteID(noteList: [NoteData]) -> Int {
        return (noteList.map{$0.id}.max() ?? -1) + 1
    }
    
//    delete note based on documentID
    public func deleteNote(email: String, uniqueID: Int, completion: @escaping (Bool) -> Void) {
        let documentID = email +  "note" + String(uniqueID)
        FireBaseProxy.shared.deleteNote(documentID: documentID, completion: { isDelete in
            completion(isDelete)
        })
    }
    
//    logout and remove user default object
    public func logOutUser() {
        UserDefaults.standard.removeObject(forKey: "username")
    }
    
}
