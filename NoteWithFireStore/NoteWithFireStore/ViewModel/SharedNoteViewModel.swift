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
    
    func updateSharedNoteForSingleUser(userToShare: String, noteToShare: Int, isEdit: Bool, completion: @escaping (Bool) -> Void) {
        let noteEmailAndID = username! + "note" + String(noteToShare)
        var noteName = ""
        if isEdit {
            noteName = noteEmailAndID + "modeedit"
        } else {
            noteName = noteEmailAndID  + "modeview"
        }
        
        FireBaseProxy.shared.updateSharedNoteForSingleUser(emailToShare: userToShare, noteEmailAndID: noteEmailAndID, noteName: noteName, completion: { isShared in
            completion(isShared)
        })
    }
    
    func updateSharedUserForSingleNote(username: String, id: Int, userToShare: String, isEdit: Bool ,completion: @escaping (Bool) -> Void) {
        var userToShareAndMode = ""
        if isEdit {
            userToShareAndMode = userToShare + "modeedit"
        } else {
            userToShareAndMode = userToShare  + "modeview"
        }
        
        FireBaseProxy.shared.updateSharedUserForSingleNote(email: username, id: id, userToShareAndMode: userToShareAndMode, userToShare: userToShare,completion: { isUpdated in
            completion(isUpdated)
        })
    }
    
//   note deleted or stop share
    func deleteOneNoteForAllSharedUsers(uniqueID: Int) {
        let noteName = username! + "note" + String(uniqueID)
        FireBaseProxy.shared.deleteOneNoteForAllSharedUsers(noteName: noteName)
    }
    
    func deleteAllSharedUsersForOneNote(uniqueID: Int){
        let documentId = username! + "note" + String(uniqueID)
        FireBaseProxy.shared.deleteAllSharedUsersForOneNote(documentId: documentId)
    }
    
//    stop share for 1 user
    func deleteOneNoteForOneUser(userToShare: String,uniqueID: Int, mode: String) {
        let noteNameWitEmailAndIDAndMode = username! + "note" + String(uniqueID) + "mode" + mode
        FireBaseProxy.shared.deleteOneNoteForOneUser(userToShare: userToShare, noteNameWitEmailAndIDAndMode: noteNameWitEmailAndIDAndMode)
    }
    
    func deleteOneUserForOneNote(id: Int, noteNameWitEmail: String, completion: @escaping (Bool) -> Void) {
        FireBaseProxy.shared.deleteOneUserForOneNote(email: username!, id: id, emailAndMode: noteNameWitEmail, completion: { deleted in
            completion(deleted)
        })
    }
    
    
    func getSharedNote(completion: @escaping ([String]) -> Void){
        FireBaseProxy.shared.getSharedNote(email: username!, completion: { sharedNoteList in
            completion(sharedNoteList)
        })
    }
    
    func getSharedUser(id: Int, completion: @escaping ([String]) -> Void){
        FireBaseProxy.shared.getSharedUsers(email: username!, id: id, completion: { sharedUserList in
            completion(sharedUserList)
        })
    }
    
    func changeModeOneNoteForOneUser(userToShare: String, uniqueID: Int, mode: String){
        let noteNameWitEmailAndID = username! + "note" + String(uniqueID)
        if mode == "view" {
            FireBaseProxy.shared.changeModeOneNoteForOneUser(userToShare: userToShare, noteNameWitEmailAndID: noteNameWitEmailAndID , mode: "edit")
        } else {
            FireBaseProxy.shared.changeModeOneNoteForOneUser(userToShare: userToShare, noteNameWitEmailAndID: noteNameWitEmailAndID, mode: "view")
        }
    }

    
    func changeModeOneUserForOneNote(id: Int, userToShare: String, mode: String, completion: @escaping (Bool) -> Void) {
        if mode == "view" {
            FireBaseProxy.shared.changeModeOneUserForOneNote(email: username!, id: id, userToShare: userToShare, mode: "edit", completion: { updatedModeSuccess in
                completion(updatedModeSuccess)
            })
        } else {
            FireBaseProxy.shared.changeModeOneUserForOneNote(email: username!, id: id, userToShare: userToShare, mode: "view", completion: { updatedModeSuccess in
                completion(updatedModeSuccess)
            })
        }
        
        
    }
    
    
    
}




//        var swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
//        if !filteredNoteList[indexPath.row].isLocked {
//            // SHARE ACTION
//            let shareAction = UIContextualAction(style: .normal, title: "Share", handler: {(contextualAction, view, boolValue) in
//                NoteViewModel.shared.getNoteList(completion: { notes in
//                    self.filteredNoteList = notes
//                    DispatchQueue.main.async {
//                        self.noteTableView.reloadData()
//                    }
//
//                    // note shared to specific users
//                    let sharedUsersStr = self.filteredNoteList[indexPath.row].sharedUsers.joined(separator: ", ")
//                    self.showShareAlert(title: "Share Note", message: "Share to: \(sharedUsersStr)",  noteToShare: self.filteredNoteList[indexPath.row].id, completion: { message in
//                        self.showResultShareAlert(title: "Shared Note", message: message)
//
//                    })
//                })
//            })
//            shareAction.backgroundColor = UIColor.blue



//        var swipeActions = [deleteAction]
//        if !filteredNoteList[indexPath.row].isLocked {
//            // SHARE ACTION
//            let shareAction = UITableViewRowAction(style: .normal, title: "Share", handler: { (action, indexPath) in
//                NoteViewModel.shared.getNoteList(completion: { notes in
//                    self.filteredNoteList = notes
//                    DispatchQueue.main.async {
//                        self.noteTableView.reloadData()
//                    }
//
//                    // note shared to specific users
//                    let sharedUsersStr = self.filteredNoteList[indexPath.row].sharedUsers.joined(separator: ", ")
//                    self.showShareAlert(title: "Share Note", message: "Share to: \(sharedUsersStr)",  noteToShare: self.filteredNoteList[indexPath.row].id, completion: { message in
//                        self.showResultShareAlert(title: "Shared Note", message: message)
//
//                    })
//                })
//            })
//
//            shareAction.backgroundColor = UIColor.blue
//            swipeActions.append(shareAction)
//        }
