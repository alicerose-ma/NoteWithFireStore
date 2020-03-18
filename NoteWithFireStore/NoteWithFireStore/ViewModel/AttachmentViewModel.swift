//
//  AttachmentViewModel.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/17/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit


class AttachmentViewModel {
    var subStr1 = ""
    var subStr2 = ""
    
    func addImage(desTextView: UITextView) {
        var cursorPosition = 0
        var text = ""
        
        if let selectedRange = desTextView.selectedTextRange {
                cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start)
        }
        text = desTextView.text!
        
        let selectedIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        subStr1 = String(text[text.startIndex..<selectedIndex])
        subStr2 = String(text[selectedIndex..<text.endIndex])
        

        let attributedString = NSMutableAttributedString(string: desTextView.text!)
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "download")!

        let oldWidth = textAttachment.image!.size.width;

        let scaleFactor = oldWidth / (desTextView.frame.size.width - 10); //for the padding inside the textView
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        var attrStringWithImage = NSAttributedString(attachment: textAttachment)


        attributedString.replaceCharacters(in: NSMakeRange(subStr1.count, 0), with: attrStringWithImage)
        
        print(attributedString as! String)
       
        desTextView.attributedText = attributedString;
        
    }
}
