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
    var noteList: [NoteData] = []
    var maxNoteList: Int = 0
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
    
    public func deleteNote(documentID: String, completion: @escaping (Bool) -> Void) {
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
    public func getSharedNote(email: String,  completion: @escaping (([NoteData]) -> Void)) {
        var sharedNotes: [String] = []
        usersCollection.whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [UserData] = try querySnapshot!.decoded()
                        sharedNotes = myUsers[0].sharedNotes
                        let oldMaxNoteList = self.maxNoteList
                        self.maxNoteList = myUsers[0].sharedNotes.count
                        
                        //                        if oldMaxNoteList != self.maxNoteList {
                        //
                        //                        }
                        for note in sharedNotes{
                            let userAndId = note.components(separatedBy: "note")
                            let id = Int(userAndId[1])
                            self.getNoteByID(email: userAndId[0], id: id!, completion: { note in
                                self.noteList.append(note[0])
                            })
                        }
                        print("AAA")
                        print(self.noteList)
                        completion(self.noteList)
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    public func updateSharedUserForSingleNote(email: String, id: Int, userToShare: String) {
        var sharedUsers: [String] = []
        
        usersCollection.document(userToShare).getDocument { (document, error) in
            if let document = document, document.exists {
                
                self.getNoteByID(email: email, id: id, completion: { notes in
                    sharedUsers = notes[0].sharedUsers
                    if !sharedUsers.contains(userToShare) {
                        sharedUsers.append(userToShare)
                    }
                    print("shared USER = \(sharedUsers)")
                    let documentId = email + "note" + String(id)
                    self.notesCollection.document(documentId).updateData([
                        "sharedUsers": sharedUsers
                    ]) { err in
                        if let err = err {
                            print("Error updating shared user: \(err)")
                        } else {
                            print("Shared user successfully updated")
                        }
                    }
                })
            }
        }
    }
    
    
    public func deleteNoteInSharedUsers(noteName: String) {
        usersCollection.whereField("sharedNotes", arrayContains: noteName).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    let myUsers: [UserData] = try querySnapshot!.decoded()
                    for user in myUsers {
                        print("username = \(user.email) delete \(user.sharedNotes)")
                        
                        var sharedNotes = user.sharedNotes
                        sharedNotes.removeAll{$0.contains(noteName)}
                        
                        print("shared Notes = \(sharedNotes)")
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
                } catch {
                    print("decoded User error")
                }
            }
        }
    }
    
    
    public func shareNoteToUser(userToShare: String, noteName: String ,completion: @escaping (Bool) -> Void) {
        usersCollection.whereField("username", isEqualTo: userToShare)
            .getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [UserData] = try querySnapshot!.decoded()
                        if myUsers.count == 1 {
                            var sharedNotes = myUsers[0].sharedNotes
                            if !sharedNotes.contains(noteName) {
                                sharedNotes.append(noteName)
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
                            completion(true)
                        } else {
                            completion(false)
                        }
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    
    
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
