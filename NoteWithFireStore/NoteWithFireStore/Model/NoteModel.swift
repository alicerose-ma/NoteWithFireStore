//
//  NoteModel.swift
//  note
//
//  Created by Ma Alice on 1/20/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

//note model in fire store
public struct NoteData: Decodable {
    var id: Int
    var email: String
    var title: String
    var des: String
    var isLocked: Bool
    var isEditing: Bool
//    var isShared: Bool
    var imageIDMax: Int
    var sharedUsers : [String]
    var imagePosition : [Int]
    var imageURL : [String]
    var lastUpdateTime: Int64
    var lastUpdateUser: String
    
//    dictionary to add to fire store
    var dictionary: [String: Any] {
        return [
            "email" : email,
            "id" : id,
            "title": title,
            "des": des,
            "isLocked": isLocked,
            "isEditing": isEditing,
//            "isShared": isShared,
            "sharedUsers" : sharedUsers,
            "imageIDMax" : imageIDMax,
            "imagePosition" : imagePosition,
            "imageURL" : imageURL,
            "lastUpdateTime": lastUpdateTime,
            "lastUpdateUser": lastUpdateUser
        ]
    }
    
}
