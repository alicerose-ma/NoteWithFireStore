//
//  FireBaseProxy.swift
//  note
//
//  Created by Ma Alice on 1/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import Firebase

public class FireBaseProxy {
    let usersCollection = Firestore.firestore().collection("Users")
    let notesCollection = Firestore.firestore().collection("Notes")
    static let shared = FireBaseProxy()
    
    private init() {}
    
    
    public func sendUserRequest(username: String, completion: @escaping (([UserData]) -> Void)) {
        usersCollection.whereField("username", isEqualTo: username)
            .getDocuments() {(querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    do {
                        let myUsers: [UserData] = try querySnapshot!.decoded()
                        print(myUsers)
                        completion(myUsers)
                    } catch {
                        print("decoded User error")
                    }
                }
        }
    }
    
    
    public func sendNoteRequest(username: String, completion: @escaping (([NoteData]) -> Void)) {
            notesCollection.whereField("username", isEqualTo: username)
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
    
//    NOTES
    public func addNewNote(documentID: String,newNote: NoteData) {
        notesCollection.document(documentID).setData(newNote.dictionary) { err in
            if let err = err {
                print("Error adding note: \(err)")
            } else {
                print("Note successfully added!")
            }
        }
    }
    
    public func getNoteByID(username: String, id: Int, completion: @escaping (([NoteData]) -> Void)) {
        notesCollection.whereField("username", isEqualTo: username)
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
    

    
    
//    USERS
    public func isNewUsernameValid(username: String, completion: @escaping (Bool) -> Void) {
        usersCollection.whereField("username", isEqualTo: username)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot!.documents.count == 0 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
        }
    }
    
    public func addNewUser(username: String, newUser: UserData, completion: @escaping (String) -> Void) {
        var addUserMessage = ""
        usersCollection.document(username).setData(newUser.dictionary) { err in
            if let err = err {
                print("Error adding user: \(err)")
                addUserMessage = "Error adding user: \(err)"
            } else {
                print("User successfully added!")
                addUserMessage = "User successfully added!"
            }
            
            completion(addUserMessage)
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

