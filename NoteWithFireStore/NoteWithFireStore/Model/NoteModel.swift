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
    var sharedUsers : [String]
//    var createdTime: String
    
    init() {
        self.username = ""
        self.id = 0
        self.title = ""
        self.des = ""
        self.isLocked = false
        self.sharedUsers = []
//        self.createdTime = ""
    }
    
    init(username: String, id: Int,title: String, des: String, isLocked: Bool, sharedUsers: [String]) {
        self.username = username
        self.id = id
        self.title = title
        self.des = des
        self.isLocked = isLocked
        self.sharedUsers = sharedUsers
//        self.createdTime = createdTime
    }
    
    
    var dictionary: [String: Any] {
        return [
            "username" : username,
            "id" : id,
            "title": title,
            "des": des,
            "isLocked": isLocked,
            "sharedUsers" : sharedUsers
        ]
    }
    
}
