//
//  ImageModel.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/22/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation

public struct ImageData: Decodable {
    var noteName: String
    var imagePosition : [Int]
    var imageURL : [String]
    
    init(noteName: String, imagePosition: [Int], imageURL: [String]) {
        self.noteName = noteName
        self.imagePosition = imagePosition
        self.imageURL = imageURL
    }
    
    var dictionary: [String: Any] {
        return [
            "noteName" : noteName,
            "imagePosition" : imagePosition,
            "imageURL" : imageURL
        ]
    }
    
}
