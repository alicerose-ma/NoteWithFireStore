//
//  AttachmentViewModel.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/17/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit

protocol ImageDelegate {
    func addURLImage(url: String)
}



public class AttachmentViewModel {
    
    //    func addURLImage(url: String) {
    //        imageURL.append(url)
    //        print("AaaaA \(imageURL)")
    //    }
    
    static let shared =  AttachmentViewModel()
    private init() {}
    
    var imageDelegate: ImageDelegate?
    
    var subStr1 = ""
    var subStr2 = ""
    var htmlString = "aaa"
    var pickedImage = UIImage()
    var stringImageURL = ""
    var attributedString = NSMutableAttributedString()
    
    var oldPosition: [Int] = []
    var oldURL: [String] = []
    var imageIDMax: Int = 0
    var imageEditLink = (username: "", noteID: "", imageName: "")
    
    var newImagePosition: [Int] = []
    var newImageURL: [String] = []
    var imageLink = (username: "", noteID: "", imageName: "")
    
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
        
        attributedString = NSMutableAttributedString(attributedString: desTextView.attributedText)
        let textAttachment = NSTextAttachment()
        textAttachment.image = pickedImage
        let oldWidth = textAttachment.image!.size.width;
        
        let scaleFactor = oldWidth / (desTextView.frame.size.width - 10); //for the padding inside the textView
        textAttachment.image = UIImage(cgImage:  textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSMutableAttributedString(attachment: textAttachment)
        attributedString.replaceCharacters(in: NSMakeRange(subStr1.count, 0), with: attrStringWithImage)
        
        desTextView.attributedText = attributedString;
        
        newImagePosition.append(cursorPosition)
        newImageURL.append("https://firebasestorage.googleapis.com/v0/b/notewithfirestore.appspot.com/o/\(imageLink.username)%2F\(imageLink.noteID)%2F\(imageLink.imageName)?alt=media")
        
        
        
        
        //        htmlString = attributedString.string
        //           if let attributedText = desTextView.attributedText {
        //               do {
        //                   let htmlData = try attributedText.data(from: .init(location: 0, length: attributedText.length),
        //                                                          documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
        //
        //                   htmlString = String(data: htmlData, encoding: .utf8) ?? ""
        //                                   print("html DAta = \(htmlString)")
        //                   let scaledWidth = desTextView.frame.size.width - 10
        //                   let scaledHeight = Double(scaledWidth) *  AttachmentViewModel.shared.height / AttachmentViewModel.shared.width
        //                   htmlString = htmlString.replacingOccurrences(of: "\"file:///Attachment_\(imageCount).png\"", with: "\"https://firebasestorage.googleapis.com/v0/b/notewithfirestore.appspot.com/o/down.jpeg?alt=media\" width=\"\(scaledWidth)\" height=\"\(scaledHeight)\"")
        //
        //                print("html data =  \(htmlString)")
        //               }catch {
        //                   print(error)
        //               }
        //        }
        
        //           }
        //
        //
        //}
        
        //        htmlString = desTextView.attributedText.string
        //        if let attributedText = desTextView.attributedText {
        //            do {
        //                let htmlData = try attributedText.data(from: .init(location: 0, length: attributedText.length),
        //                                                       documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
        //
        //                htmlString = String(data: htmlData, encoding: .utf8) ?? ""
        ////                print("html DAta = \(htmlString)")
        //                //                AttachmentViewModel.htmlString = AttachmentViewModel.htmlString.replacingOccurrences(of: "\"file:///Attachment.png\"", with: "\"\(stringImageURL)\" width=\"\(scaledWidth)\" height=\"\(scaledHeight)\"")
        //                htmlString = htmlString.replacingOccurrences(of: "\"file:///Attachment.png\"", with: "\"https://firebasestorage.googleapis.com/v0/b/notewithfirestore.appspot.com/o/download.jpeg?alt=media\" width=\"\(scaledWidth)\" height=\"\(scaledHeight)\"")
        //
        //
        //
        //                  let test =   "Attachment_1 abc efd Attachment_2"
        //                  let match = matches(for: "Attachment_^[1-9]", in: test)
        //                  print("AAA")
        //                  print(match)
        //
        //
        //            } catch {
        //                print(error)
        //            }
        //        }
        //    }
        //
        //
        //    func matches(for regex: String, in text: String) -> [String] {
        //
        //        do {
        //            let regex = try NSRegularExpression(pattern: regex)
        //            let nsString = text as NSString
        //            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        //            return results.map { nsString.substring(with: $0.range)}
        //        } catch let error {
        //            print("invalid regex: \(error.localizedDescription)")
        //            return []
        //        }
        //    }
        //}
        
        //        let scaledWidth = desTextView.frame.size.width - 10
        //        let scaledHeight = Double(scaledWidth) * height / width
        
    }
    
    
    
    func editImage(desTextView: UITextView){
        var cursorPosition = 0
        var text = ""
        if let selectedRange = desTextView.selectedTextRange {
            cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start)
        }
        text = desTextView.text!
        let selectedIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        subStr1 = String(text[text.startIndex..<selectedIndex])
        subStr2 = String(text[selectedIndex..<text.endIndex])
        
        attributedString = NSMutableAttributedString(attributedString: desTextView.attributedText)
        let textAttachment = NSTextAttachment()
        textAttachment.image = pickedImage
        let oldWidth = textAttachment.image!.size.width;
        
        let scaleFactor = oldWidth / (desTextView.frame.size.width - 10); //for the padding inside the textView
        textAttachment.image = UIImage(cgImage:  textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSMutableAttributedString(attachment: textAttachment)
        attributedString.replaceCharacters(in: NSMakeRange(subStr1.count, 0), with: attrStringWithImage)
        
        desTextView.attributedText = attributedString;
        
        imageIDMax += 1
        oldPosition.append(cursorPosition)
    oldURL.append("https://firebasestorage.googleapis.com/v0/b/notewithfirestore.appspot.com/o/\(imageLink.username)%2F\(imageLink.noteID)%2F\(imageLink.imageName)?alt=media")
    }
}


