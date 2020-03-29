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
    var username: String
    var title: String
    var des: String
    var isLocked: Bool
    var imageIDMax: Int
    var sharedUsers : [String]
    var imagePosition : [Int]
    var imageURL : [String]
    
//    dictionary to add to fire store
    var dictionary: [String: Any] {
        return [
            "username" : username,
            "id" : id,
            "title": title,
            "des": des,
            "isLocked": isLocked,
            "sharedUsers" : sharedUsers,
            "imageIDMax" : imageIDMax,
            "imagePosition" : imagePosition,
            "imageURL" : imageURL
        ]
    }
    
}
