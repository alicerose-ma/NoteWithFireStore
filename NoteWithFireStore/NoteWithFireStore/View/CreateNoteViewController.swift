//
//  CreateNoteViewController.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit
import Speech

enum InputPasscodeCase: String {
    case editPasscode
    case unlockNote
}

class CreateNoteViewController: UIViewController, SetPasscodeDelegate, Alertable, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var imagePicker = UIImagePickerController()
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var cursorPosition = 0
        if text.isBackspace {
            if let selectedRange = desTextView.selectedTextRange {
                cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start) - 1
                print("cursor REMOVE")
                print(cursorPosition)
            }
            if cursorPosition != -1 {
                var deleteImage = false
                let imagePositionArr = AttachmentViewModel.shared.newImagePosition
                
                for (index, position) in imagePositionArr.enumerated() {
                    if cursorPosition < position  {
                        if let selectedRange = desTextView.selectedTextRange {
                        print("delete with selection")
                            guard let selectedText = desTextView.text(in: selectedRange) else { return false }
                            if !deleteImage {
                                if selectedText.count == 0 {
                                    AttachmentViewModel.shared.newImagePosition[index] = position - 1
                                } else {
                                    AttachmentViewModel.shared.newImagePosition[index] = position - selectedText.count
                                }
                            } else {
                                if selectedText.count == 0 {
                                    AttachmentViewModel.shared.newImagePosition[index - 1] = position - 1
                                } else {
                                    AttachmentViewModel.shared.newImagePosition[index - 1] = position - selectedText.count
                                }
                            }
                        }
//                        } else {
//                            print("delete 1")
//                            if !deleteImage {
//
//                            } else {
//
//                        }
                    } else if cursorPosition == position {
                        deleteImage = true
                        AttachmentViewModel.shared.newImagePosition.remove(at: index)
                        AttachmentViewModel.shared.newImageURL.remove(at: index)
                    }
                }
                
//                if let selectedRange = desTextView.selectedTextRange {
//                    guard let selectedText = desTextView.text(in: selectedRange) else { return false }
//                if !deleteImage {
//                    AttachmentViewModel.shared.newImagePosition[index] = position - 1
//                } else {
//                    AttachmentViewModel.shared.newImagePosition[index-1] = position - 1
//                }
//
//
            } else {
                cursorPosition = 0
            }
            
        } else {
            if let selectedRange = desTextView.selectedTextRange {
                cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start) + 1
                print("cursor ADD")
                print(cursorPosition)
            }
            let imagePositionArr = AttachmentViewModel.shared.newImagePosition
            for (index, position) in imagePositionArr.enumerated() {
                if cursorPosition <= position + 1 {
                    if let selectedRange = desTextView.selectedTextRange {
                        guard let selectedText = desTextView.text(in: selectedRange) else { return false }
                        //                        REPLACE
                        //                        if text.count > 1 {
                        print("Add whole")
                        print("Count: \(text.count)")
                        print("Selected: \(selectedText.count )")
                        AttachmentViewModel.shared.newImagePosition[index] = position - selectedText.count + text.count
                        //                        } else {
                        //                            AttachmentViewModel.shared.newImagePosition[index] = position - selectedText.count + 1
                        //                        }
                        //                    } else {
                        ////                        COPY & PASTE + TYPE
                        //                        if text.count > 1 {
                        //                            print("Add 1")
                        //                            print("Count: \(text.count)")
                        //                            AttachmentViewModel.shared.newImagePosition[index] = position + text.count
                        //                        } else {
                        //                            AttachmentViewModel.shared.newImagePosition[index] = position + 1
                        //                        }
                    }
                }
            }
        }
        print("cursor Array NEW")
        print(AttachmentViewModel.shared.newImagePosition)
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let localPath = documentDirectory?.appending(imgName)
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let data = image.pngData()! as NSData
            data.write(toFile: localPath!, atomically: true)
            let photoURL = URL.init(fileURLWithPath: localPath!)//NSURL(fileURLWithPath: localPath!)
            AttachmentViewModel.shared.stringImageURL = "\(photoURL)"
            
            let types = AttachmentViewModel.shared.stringImageURL.components(separatedBy: ".")
            let noteID = CreateNoteViewModel.shared.createUniqueNoteDocID(username: CreateNoteViewModel.shared.username!, uniqueID: uniqueID)
            imageID += 1
            let imageName = noteID + String(imageID)
            let name = imageName + ".\(types[1])"
            
            AttachmentViewModel.shared.imageLink = (username: CreateNoteViewModel.shared.username! , noteID: noteID, imageName: name)
            FireBaseProxy.shared.uploadImage(urlImgStr: photoURL,username: CreateNoteViewModel.shared.username!, noteID: noteID, imageName: name)
        }
        
        if let possibleImage = info[.editedImage] as? UIImage {
            AttachmentViewModel.shared.pickedImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            AttachmentViewModel.shared.pickedImage = possibleImage
        } else {
            return
        }
        AttachmentViewModel.shared.addImage(desTextView: desTextView)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VoiceViewModel.shared.stopRecording()
        let title = titleTextField.text!
        let description = desTextView.attributedText.string
        let imagePosition = AttachmentViewModel.shared.newImagePosition
        let imageURL = AttachmentViewModel.shared.newImageURL
        
        let noteID = CreateNoteViewModel.shared.createUniqueNoteDocID(username: CreateNoteViewModel.shared.username!, uniqueID: uniqueID)
        let note = NoteData(username: CreateNoteViewModel.shared.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus, sharedUsers: [], imageIDMax: imageID, imagePosition: imagePosition, imageURL: imageURL )
        
        if !title.isEmpty && !desTextView.attributedText.string.isEmpty  {
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        } else if title.isEmpty && !desTextView.attributedText.string.isEmpty {
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        } else if !title.isEmpty && desTextView.attributedText.string.isEmpty {
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        }
        
        AttachmentViewModel.shared.newImagePosition = []
        AttachmentViewModel.shared.newImageURL = []
        AttachmentViewModel.shared.imageLink = (username: "", noteID: "", imageName: "")
        imageID = -1
    }
    
    
    @IBOutlet weak var recordOutlet: UIButton!
    var alert = UIAlertController()
    
    var uniqueID: Int = 0
    var hasLock: Bool = false
    var lockStatus: Bool = false
    var isRecord: Bool = false
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var lockStatusBtn = UIBarButtonItem()
    var unlockStatusBtn = UIBarButtonItem()
    var voiceBtn = UIBarButtonItem()
    var imageBtn = UIBarButtonItem()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    var imageID: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        desTextView.delegate = self
        imagePicker.delegate = self 
        lockView.isHidden = true
        navBarItemSetUp()
        voiceBtn.isEnabled = false
        imageBtn.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
        VoiceViewModel.shared.voiceSetupWithoutRecordBtn()
    }
    
    func navBarItemSetUp() {
        insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(addOrRemoveLock))
        lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
        unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
        voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
        imageBtn = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(self.addImage))
    }
    
    
    @objc func addImage(){
        showImageAlert(imagePicker: imagePicker)
    }
    
    
    //    TEXT DESCRIBED FROM VOICE
    @objc func voice(){
        VoiceViewModel.shared.clickRecordBtn(titleTextField: titleTextField, desTextView: desTextView)
        if isRecord {
            isRecord = false
            voiceBtn.image = UIImage(systemName: "mic")
        } else {
            isRecord = true
            voiceBtn.image = UIImage(systemName: "mic.slash")
        }
    }
    
    //    switch between textfield and textview, stop record
    func textFieldDidBeginEditing(_ textField: UITextField) {
        VoiceViewModel.shared.stopRecording()
        voiceBtn.isEnabled = true
        imageBtn.isEnabled = false
        isRecord = false
        voiceBtn.image = UIImage(systemName: "mic")
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        VoiceViewModel.shared.stopRecording()
        voiceBtn.isEnabled = true
        imageBtn.isEnabled = true
        isRecord = false
        voiceBtn.image = UIImage(systemName: "mic")
    }
    
    
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
        
    }
    
    
    //    delegate to add lock status
    func addLockIconToNavBar() {
        hasLock = true
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,unlockStatusBtn]
    }
    
    @objc func addOrRemoveLock() {
        showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: hasLock)
    }
    
    func showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: Bool) {
        let alert = UIAlertController(title: "Lock Note", message: "Select Lock Options" , preferredStyle: .actionSheet)
        
        if hasLock {
            alert.addAction(UIAlertAction(title: "Remove Lock", style: .default, handler: { (_) in
                self.hasLock = false
                self.navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn,self.voiceBtn, self.imageBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                self.hasLock = true
                SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
                    if passcode == "" {
                        self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                    } else {
                        self.addLockIconToNavBar()
                    }
                })
            }))
        }
        
        //        edit passcode action
        SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
            if passcode != "" {
                alert.addAction(UIAlertAction(title: "Edit Passcode", style: .default, handler: { (_) in
                    SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
                        self.enterPasscodeAlert(passcode: passcode, passcodeCase: .editPasscode)
                    })
                }))
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    //    note is locked
    @objc func lockON(){
        lockStatus = true
        lockView.isHidden = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,lockStatusBtn]
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
        voiceBtn.isEnabled = false
        imageBtn.isEnabled = false
    }
    
    //    note is unlocked
    @objc func lockOFF() {
        SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
    }
    
    @objc func showAndHiddenPasscodeAction(_ sender: Any) {
        CreateNoteViewModel.shared.displayPasscode(alert: alert)
    }
    
    
    //    enter passcode to edit and unlock
    func enterPasscodeAlert(passcode: String, passcodeCase: InputPasscodeCase) {
        alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            textField.isSecureTextEntry = true
            
            CreateNoteViewModel.shared.setPasscodeIcon(name: "eye", textField: textField)
            CreateNoteViewModel.shared.micStart.addTarget(self, action: #selector(self.showAndHiddenPasscodeAction), for: .touchUpInside)
            textField.rightView = CreateNoteViewModel.shared.micStart
            textField.rightViewMode = .always
            
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = self.alert.textFields?.first?.text {
                if password == passcode {
                    switch passcodeCase {
                    case .editPasscode:
                        self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                    case .unlockNote:
                        self.lockStatus = false
                        self.lockView.isHidden = true
                        self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
                        self.addLockIconToNavBar()
                    }
                } else {
                    self.showAlert(title: .passcodeValidation, message: .wrong)
                }
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassView" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
        }
    }
    
    
    
    
    
    
    
    
}



//        if let attributedText = desTextView.attributedText {
//            do {
//                let htmlData = try attributedText.data(from: .init(location: 0, length: attributedText.length),
//                                                       documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
//
//                htmlString = String(data: htmlData, encoding: .utf8) ?? ""
//                print("html DAta = \(htmlString)")
//
//                let scaledWidth = desTextView.frame.size.width - 10
//                let scaledHeight = Double(scaledWidth) *  AttachmentViewModel.shared.height / AttachmentViewModel.shared.width
//                htmlString = htmlString.replacingOccurrences(of: "\"file:///Attachment.png\"", with: "\"https://firebasestorage.googleapis.com/v0/b/notewithfirestore.appspot.com/o/down.jpeg?alt=media\" width=\"\(scaledWidth)\" height=\"\(scaledHeight)\"")
//
//
//                htmlString = htmlString.replacingOccurrences(of: "\"file:///Attachment_1.png\"", with: "\"https://firebasestorage.googleapis.com/v0/b/notewithfirestore.appspot.com/o/down.jpeg?alt=media\" width=\"\(scaledWidth)\" height=\"\(scaledHeight)\"")
//            }catch {
//                print(error)
//            }
//        }



//        if text.contains(UIPasteboard.general.string ?? "") {
//            if let selectedRange = desTextView.selectedTextRange {
//                cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start) - 1
//            }
//
//            let imagePositionArr = AttachmentViewModel.shared.newImagePosition
//            for (index, position) in imagePositionArr.enumerated() {
//                if cursorPosition < position  {
//                    AttachmentViewModel.shared.newImagePosition[index] = position + UIPasteboard.general.string!.count
//                }
//
//            }
//            return true
//        }








