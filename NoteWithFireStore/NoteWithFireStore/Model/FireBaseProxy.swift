//
//  FireBaseProxy.swift
//  note
//
//  Created by Ma Alice on 1/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit
import Firebase

public class FireBaseProxy {
    let usersCollection = Firestore.firestore().collection("Users")
    let notesCollection = Firestore.firestore().collection("Notes")
    let imagesCollection = Firestore.firestore().collection("Images")

    var finalSharedNotes: [NoteData] = []
    var finalModeArr: [String] = []
    var aa: [NoteData] = []
    
    var arr : [NoteData] = []

    var alert =  UIAlertController()
    var loadingIndicator = UIActivityIndicatorView()
    
    static let shared = FireBaseProxy()
    private init() {}
    
    //  MARK: - USERS
    //    sign up to auth
    func signup(email: String, password: String, displayName: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                print("sign up success")
                completion(true)
            } else {
                print("create new user err \(String(describing: error))")
                completion(false)
            }
        }
    }
    
    //    create database account
    public func addNewUserToDatabase(email: String, newUser: UserData, completion: @escaping (Bool, String) -> Void) {
        var addUserMessage = ""
        var isSuccess = false
        usersCollection.document(email).setData(newUser.dictionary) { err in
            if let err = err {
                print("Error adding user: \(err)")
                addUserMessage = "New user created failed"
            } else {
                print("User successfully added!")
                addUserMessage = "New user created successed"
                isSuccess = true
            }
            completion(isSuccess,addUserMessage)
        }
    }
    
    //    login with email
    func login(email: String, password: String, completion: @escaping (Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print("login in err")
                completion(false)
            } else {
                print("login done")
                completion(true)
            }
        }
    }
    
    //    check if user did login before
    func didLogin(completion: @escaping (Bool, String) -> Void) {
        if Auth.auth().currentUser != nil {
            let email = Auth.auth().currentUser?.email!
            completion(true, email!)
        } else {
            print("No user login")
            completion(false, "")
        }
    }
    
    //    exit and sign out auth
    func exit() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    
    //  MARK: - NOTE REQUESTS
    func getNoteList(email: String, completion: @escaping (([NoteData]) -> Void)) {
        notesCollection.whereField("email", isEqualTo: email)
            .getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let notes: [NoteData] = try querySnapshot!.decoded()
                        completion(notes)
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    public func getNoteByID(email: String, id: Int, completion: @escaping (([NoteData]) -> Void)) {
        notesCollection.whereField("email", isEqualTo: email)
            .whereField("id", isEqualTo: id).getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let notes: [NoteData] = try querySnapshot!.decoded()
                        completion(notes)
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    
    public func addNewNote(documentID: String,newNote: NoteData) {
        notesCollection.document(documentID).setData(newNote.dictionary) { err in
            if let err = err {
                print("Error adding note: \(err)")
            } else {
                print("Note successfully added!")
            }
        }
    }
    
    public func editNote(documentID: String,  newNote: NoteData) {
        notesCollection.document(documentID).updateData(newNote.dictionary) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    public func deleteNote(documentID: String) {
        notesCollection.document(documentID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    //  MARK: -  PASSCODE UPDATE
    public func updateUserPasscode(email: String, passcode: String, hint: String, completion: @escaping (Bool) -> Void){
        usersCollection.document(email).updateData([
            "passcode": passcode,
            "hint": hint,
        ]) { err in
            if let err = err {
                print("Error updating passcode: \(err)")
                completion(false)
            } else {
                print("Passcode successfully updated")
                completion(true)
            }
        }
    }
    
    public func getUserPasscode(email: String, completion: @escaping (String, String) -> Void) {
        usersCollection.whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [UserData] = try querySnapshot!.decoded()
                        print(myUsers[0].passcode)
                        completion(myUsers[0].passcode, myUsers[0].hint)
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    
    //  MARK: - SHARE
    public func getSharedNote(email: String, completion: @escaping ([(NoteData, String)]) -> Void) {
        var sharedNotes: [String] = []
        var noteDataList: [(NoteData, String)] = []
        usersCollection.whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [UserData] = try querySnapshot!.decoded()
                        sharedNotes = myUsers[0].sharedNotes
                        let dispatchGroup = DispatchGroup.init()
                        for noteStr in sharedNotes {
                            dispatchGroup.enter()
                            let emailAndIDWithMode = noteStr.components(separatedBy: "note")
                            let idAndMode = emailAndIDWithMode[1].components(separatedBy: "mode")
                            
                            let email = emailAndIDWithMode[0]
                            let id = Int(idAndMode[0])!
                            let mode = idAndMode[1]
                            self.getNoteByID(email: email, id: id, completion: { notes in
                                noteDataList.append((notes[0],mode))
                                dispatchGroup.leave()
                            })
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            completion(noteDataList)
                        }
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    
//    public func getNoteArr(strArr: [[String]], completion: @escaping (([NoteData]) -> Void)) {
//        let dispatchGroup = DispatchGroup.init()
//        for str in strArr {
//            dispatchGroup.enter()
//            getNoteByID(email: str[0], id: Int(str[1])!, completion: { notes in
//                self.arr.append(notes[0])
//                dispatchGroup.leave()
//                print("leave")
//            })
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            print("finish")
//            print("firebase = \(self.arr)")
//            completion(self.arr)
//            self.arr = []
//        }
//    }
    
    

    
  
    
    //    MARK: - UPDATE NOTE & USER
    //    update user for Single note
    public func updateSharedUserForSingleNote(email: String, id: Int, userToShareAndMode: String, userToShare: String, completion: @escaping (Bool) -> Void) {
        usersCollection.document(userToShare).getDocument { (document, error) in
            if let document = document, document.exists {
                self.getNoteByID(email: email, id: id, completion: { notes in
                    var sharedUsers = notes[0].sharedUsers
                    if !sharedUsers.contains(where: {$0.contains(userToShare)}) {
                        sharedUsers.append(userToShareAndMode)
                        let documentId = email + "note" + String(id)
                        self.notesCollection.document(documentId).updateData([
                            "sharedUsers": sharedUsers
                        ]) { err in
                            if let err = err {
                                print("Error updating shared user: \(err)")
                                completion(false)
                            } else {
                                print("Shared user successfully updated")
                                completion(true)
                            }
                        }
                    } else {
                        completion(false)
                        print("Shared user exists")
                    }
                })
            } else {
                print("Err for document exists")
            }
        }
    }
    
    
    //  update note to a user
    public func updateSharedNoteForSingleUser(emailToShare: String, noteEmailAndID: String ,noteName: String ,completion: @escaping (Bool) -> Void) {
        usersCollection.whereField("email", isEqualTo: emailToShare)
            .getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [UserData] = try querySnapshot!.decoded()
                        if myUsers.count == 1 {
                            var sharedNotes = myUsers[0].sharedNotes
                            if !sharedNotes.contains(where: {$0.contains(noteEmailAndID)}) {
                                sharedNotes.append(noteName)
                            }
                            self.usersCollection.document(emailToShare).updateData([
                                "sharedNotes": sharedNotes,
                            ]) { err in
                                if let err = err {
                                    completion(false)
                                    print("Error updating shared Notes: \(err)")
                                } else {
                                    completion(true)
                                    print("Shared note successfully updated")
                                }
                            }
                        } else {
                            completion(false)
                            print("err with wrong email")
                        }
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
  
//    MARK: - GET SHARED USER  & NOTE
//    get shared Users
    public func getSharedUsers(email: String, id: Int, completion: @escaping (([String]) -> Void)) {
        notesCollection.whereField("email", isEqualTo: email)
        .whereField("id", isEqualTo: id).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    let myNote: [NoteData] = try querySnapshot!.decoded()
                    let sharedUserList: [String] = myNote[0].sharedUsers
                    completion(sharedUserList)
                } catch {
                    print("decoded User error")
                }
            }
        }
    }
    
    
//    MARK: - DELETE NOTE
    
//    click stop share => empty the shared users list for  note
    public func deleteAllSharedUsersForOneNote(documentId: String) {
        self.notesCollection.document(documentId).updateData([
            "sharedUsers": []
        ]) { err in
            if let err = err {
                print("Error delete ALL shared user: \(err)")
            } else {
                print("Delete ALL shared users successful")
            }
        }
    }
    
    
    
    
    
//  Note is deleted
    public func deleteOneNoteForAllSharedUsers(noteName: String) {
        usersCollection.whereField("sharedNotes", arrayContains: noteName + "modeview").getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    let myUsers: [UserData] = try querySnapshot!.decoded()
                    if myUsers.count != 0 {
                        for user in myUsers {
                            var sharedNotes = user.sharedNotes
                            for (index,note) in sharedNotes.enumerated() {
                                if note.contains(noteName) {
                                    sharedNotes.remove(at: index)
                                    break
                                }
                            }
                            self.usersCollection.document(user.email).updateData([
                                "sharedNotes": sharedNotes,
                            ]) { err in
                                if let err = err {
                                    print("Error updating shared Notes: \(err)")
                                } else {
                                    print("Shared note successfully updated")
                                }
                            }
                        }
                    }
                } catch {
                    print("decoded User error")
                }
            }
        }
        
        usersCollection.whereField("sharedNotes", arrayContains: noteName + "modeedit").getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    let myUsers: [UserData] = try querySnapshot!.decoded()
                    if myUsers.count != 0 {
                        for user in myUsers {
//                            print("username = \(user.email) delete \(user.sharedNotes)")
                            var sharedNotes = user.sharedNotes
                            for (index,note) in sharedNotes.enumerated() {
                                if note.contains(noteName) {
                                    sharedNotes.remove(at: index)
                                    break
                                }
                            }
                            self.usersCollection.document(user.email).updateData([
                                "sharedNotes": sharedNotes,
                            ]) { err in
                                if let err = err {
                                    print("Error updating shared Notes: \(err)")
                                } else {
                                    print("Shared note successfully updated")
                                }
                            }
                        }
                    }
                } catch {
                    print("decoded User error")
                }
            }
        }
    }
    
    
    public func deleteOneNoteForOneUser(userToShare: String, noteNameWitEmailAndIDAndMode: String,  completion: @escaping (Bool) -> Void) {
        //        combine email  + note from view controller  AND get indexPath.row extract mode from anh@gmail.commodeview
        usersCollection.whereField("email", isEqualTo: userToShare).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    let myUsers: [UserData] = try querySnapshot!.decoded()
                    print(myUsers[0])
                    var sharedNotes = myUsers[0].sharedNotes
                    sharedNotes.removeAll{$0.contains(noteNameWitEmailAndIDAndMode)}
                    self.usersCollection.document(userToShare).updateData([
                        "sharedNotes": sharedNotes,
                    ]) { err in
                        if let err = err {
                            completion(false)
                            print("Error updating shared Notes: \(err)")
                        } else {
                            completion(true)
                            print("Shared note successfully updated")
                        }
                    }
                } catch {
                    print("decoded User error")
                }
            }
        }
    }
    
    public func deleteOneUserForOneNote(email: String, id: Int, emailAndMode: String, completion: @escaping (Bool) -> Void) {
        notesCollection.whereField("email", isEqualTo: email)
            .whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [NoteData] = try querySnapshot!.decoded()
                        var sharedUsers = myUsers[0].sharedUsers
                        sharedUsers.removeAll{$0.contains(emailAndMode)}
                        let documentId = email + "note" + String(id)
                        self.notesCollection.document(documentId).updateData([
                            "sharedUsers": sharedUsers,
                        ]) { err in
                            if let err = err {
                                print("Error updating shared Notes: \(err)")
                                completion(false)
                            } else {
                                print("Shared note successfully updated")
                                completion(true)
                            }
                        }
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    
//    MARK: - CHANGE MODE
    public func changeModeOneNoteForOneUser(userToShare: String, noteNameWitEmailAndID: String, mode: String) {
        usersCollection.whereField("email", isEqualTo: userToShare).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    let myUsers: [UserData] = try querySnapshot!.decoded()
                    var sharedNotes = myUsers[0].sharedNotes
                    for (index,note) in sharedNotes.enumerated() {
                        if note.contains(noteNameWitEmailAndID) {
                            sharedNotes[index] = noteNameWitEmailAndID + "mode" + mode
                            break
                        }
                    }
                    self.usersCollection.document(userToShare).updateData([
                        "sharedNotes": sharedNotes,
                    ]) { err in
                        if let err = err {
                            print("Error updating shared Notes: \(err)")
                        } else {
                            print("Shared note successfully updated")
                        }
                    }
                } catch {
                    print("decoded User error")
                }
            }
        }
    }
    
//    email = nguyen, email +mode = anh@gmail.comnoteview
    public func changeModeOneUserForOneNote(email: String, id: Int, userToShare: String, mode: String ,completion: @escaping (Bool) -> Void) {
        notesCollection.whereField("email", isEqualTo: email)
            .whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [NoteData] = try querySnapshot!.decoded()
                        var sharedUsers = myUsers[0].sharedUsers
                        for (index, user) in sharedUsers.enumerated() {
                            if user.contains(userToShare) {
                                sharedUsers[index] = userToShare + "mode" + mode
                                break
                            }
                        }
                        let documentId = email + "note" + String(id)
                        self.notesCollection.document(documentId).updateData([ //anh@gmail.commodeview
                            "sharedUsers": sharedUsers,
                        ]) { err in
                            if let err = err {
                                print("Error updating shared Notes: \(err)")
                                completion(false)
                            } else {
                                print("Shared note successfully updated")
                                completion(true)
                            }
                        }
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    
   
    
    
    
    //    MARK: - IMAGE
    func uploadImage(urlImgStr: URL, username: String,noteID: String ,imageName: String){
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(username)/\(noteID)/\(imageName)")
        
        let uploadTask = imageRef.putFile(from: urlImgStr, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("CANNOT UPLOAD IMAGE")
                return
            }
            imageRef.downloadURL { (url, error) in
                guard url != nil else {
                    // Uh-oh, an error occurred!
                    print("CANNOT DOWNLOAD IMAGE")
                    return
                }
            }
        }
    }
    
    
    
    
}
// decodable 1 single document
extension QueryDocumentSnapshot {
    func decoded<Type: Decodable>() throws -> Type {
        
        let jsonData = try JSONSerialization.data(withJSONObject: data(), options: [])
        let object = try JSONDecoder().decode(Type.self, from: jsonData)
        return object
    }
}

// decodable snapshot (all documents)
extension QuerySnapshot {
    func decoded<Type: Decodable>() throws ->[Type] {
        let objects: [Type] = try documents.map({
            try $0.decoded()
        })
        
        return objects
    }
}



//                    if !sharedUsers.contains(userToShare) {
//                        sharedUsers.append(userToShare)
//                        print("shared USER = \(sharedUsers)")
//                        let documentId = email + "note" + String(id)
//                        self.notesCollection.document(documentId).updateData([
//                            "sharedUsers": sharedUsers
//                        ]) { err in
//                            if let err = err {
//                                print("Error updating shared user: \(err)")
//                                completion(false)
//                            } else {
//                                print("Shared user successfully updated")
//                                completion(true)
//                            }
//                        }



//                            var isContained = false
//                            for note in sharedNotes {
//                                if !note.contains(noteEmailAndID) {
//                                    isContained = false
//                                } else {
//                                    isContained = true
//                                    break
//                                }
//                            }
//
//                            if !isContained {
//                                sharedNotes.append(noteName)
//                            }

