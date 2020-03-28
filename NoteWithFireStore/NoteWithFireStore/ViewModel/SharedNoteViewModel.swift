//
//  SharedNoteViewModel.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/25/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

public class SharedNoteViewModel {
    static let shared =  SharedNoteViewModel()
    private init() {}
    
    var username: String? = UserDefaults.standard.string(forKey: "username")
    var sharedUsers: [String] = []
    var sharedNotes = [NoteData]()
    
    func share(userToShare: String, noteToShare: Int,  completion: @escaping (String) -> Void) {
        let noteName = username! + "note" + String(noteToShare)
        FireBaseProxy.shared.shareNoteToUser(userToShare: userToShare, noteName: noteName, completion: { isShared in
            if isShared {
                completion("Note shared successfully")
            } else {
                completion("Username is invalid")
            }
        })
    }
    
    func updateUserForNote(username: String, id: Int, userToShare: String) {
        FireBaseProxy.shared.updateSharedUserForSingleNote(username: username, id: id, userToShare: userToShare)
    }
    
    func deleteNoteInSharedUsers(uniqueID: Int) {
        let noteName = username! + "note" + String(uniqueID)
        FireBaseProxy.shared.deleteNoteInSharedUsers(noteName: noteName)
    }
    
    
    func getSharedNote(username: String, completion: @escaping ([NoteData]) -> Void){
        FireBaseProxy.shared.getSharedNote(username: username, completion: { notes in
            completion(notes)
        })
    }
}
