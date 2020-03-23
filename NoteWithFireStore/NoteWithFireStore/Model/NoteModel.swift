//
//  NoteModel.swift
//  note
//
//  Created by Ma Alice on 1/20/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

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
//    var createdTime: String
    
    init(username: String, id: Int,title: String, des: String, isLocked: Bool, sharedUsers: [String], imageIDMax: Int, imagePosition: [Int], imageURL: [String]) {
        self.username = username
        self.id = id
        self.title = title
        self.des = des
        self.isLocked = isLocked
        self.sharedUsers = sharedUsers
        self.imageIDMax = imageIDMax
        self.imagePosition = imagePosition
        self.imageURL = imageURL
//        self.createdTime = createdTime
    }
    
    
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
