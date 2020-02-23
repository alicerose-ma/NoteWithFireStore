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
    
    init() {
        self.username = ""
        self.id = 0
        self.title = ""
        self.des = ""
        self.isLocked = false
    }
    
    init(username: String, id: Int,title: String, des: String, isLocked: Bool) {
        self.username = username
        self.id = id
        self.title = title
        self.des = des
        self.isLocked = isLocked
    }
    
    
    var dictionary: [String: Any] {
        return [
            "username" : username,
            "id" : id,
            "title": title,
            "des": des,
            "isLocked": isLocked
        ]
    }
    
}
