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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        desTextView.delegate = self
        imagePicker.delegate = self
        navBarItemSetUp()
        lockView.isHidden = true
        voiceBtn.isEnabled = false
        imageBtn.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
        VoiceViewModel.shared.voiceSetupWithoutRecordBtn()
    }
    
    func createBarButtonItem(name: String, action: Selector)  -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: name), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        return button
    }
    
    func navBarItemSetUp() {
        insertLockForNoteBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(addOrRemoveLock))
        if #available(iOS 13.0, *) {
            lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
            unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
            voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
            imageBtn = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(self.addImage))
        } else {
            lockStatusBtn = UIBarButtonItem(customView: createBarButtonItem(name: "lock", action:  #selector(self.lockOFF)))
            unlockStatusBtn = UIBarButtonItem(customView: createBarButtonItem(name: "lockOpen", action:  #selector(self.lockON)))
            voiceBtn = UIBarButtonItem(customView: createBarButtonItem(name: "mic", action:  #selector(self.voice)))
            imageBtn = UIBarButtonItem(customView: createBarButtonItem(name: "photo", action:  #selector(self.addImage)))
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VoiceViewModel.shared.stopRecording()
        let title = titleTextField.text!
        let description = desTextView.attributedText.string
        let imagePosition = AttachmentViewModel.shared.newImagePosition
        let imageURL = AttachmentViewModel.shared.newImageURL
        
        let noteID = CreateNoteViewModel.shared.createUniqueNoteDocID(username: NoteViewModel.shared.username!, uniqueID: uniqueID)
        let note = NoteData(username: NoteViewModel.shared.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus, sharedUsers: [], imageIDMax: imageID, imagePosition: imagePosition, imageURL: imageURL )
        
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
    

//  MARK: -  TEXT DESCRIBED FROM VOICE
    @objc func voice(){
        VoiceViewModel.shared.clickRecordBtn(titleTextField: titleTextField, desTextView: desTextView)
        if isRecord {
            isRecord = false
            imageBtn.isEnabled = true
            insertLockForNoteBtn.isEnabled = true
            changeNavButtonItemForIOS12AndIOS13(name: "mic")
            
        } else {
            isRecord = true
            imageBtn.isEnabled = false
            insertLockForNoteBtn.isEnabled = false
            if #available(iOS 13.0, *) {
                voiceBtn.image = UIImage(systemName: "mic.slash")
            } else {
                 voiceBtn = UIBarButtonItem(customView: createBarButtonItem(name: "micSlash", action:  #selector(self.voice)))
                 navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
            }
            
        }
    }
    
    //    switch between textfield and textview, stop record
    func textFieldDidBeginEditing(_ textField: UITextField) {
        VoiceViewModel.shared.stopRecording()
        insertLockForNoteBtn.isEnabled = true
        voiceBtn.isEnabled = true
        imageBtn.isEnabled = false
        isRecord = false
        changeNavButtonItemForIOS12AndIOS13(name: "mic")
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        VoiceViewModel.shared.stopRecording()
        insertLockForNoteBtn.isEnabled = true
        voiceBtn.isEnabled = true
        imageBtn.isEnabled = true
        isRecord = false
        changeNavButtonItemForIOS12AndIOS13(name: "mic")
    }
    
    
    func changeNavButtonItemForIOS12AndIOS13(name: String){
        if #available(iOS 13.0, *) {
            voiceBtn.image = UIImage(systemName: name)
        } else {
            voiceBtn = UIBarButtonItem(customView: createBarButtonItem(name: name, action:  #selector(self.voice)))
            if hasLock {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,unlockStatusBtn]
            } else {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
            }
        }
        
    }
    
    
//  MARK: -  LOCK NOTE WITH PASSCODE
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
    
//    alert to add, remove or edit passcode
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
        
        SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in         // edit passcode action
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
        VoiceViewModel.shared.stopRecording()
        voiceBtn = UIBarButtonItem(customView: createBarButtonItem(name: "mic", action:  #selector(self.voice)))
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
//        PasscodeViewModel.shared.displayPasscode(textField: (alert.textFields?.first)!)
    }
    
    
    //    enter passcode to edit and unlock
    func enterPasscodeAlert(passcode: String, passcodeCase: InputPasscodeCase) {
        alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
             PasscodeViewModel.shared.isHidden = false
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            textField.isSecureTextEntry = true
            
//            PasscodeViewModel.shared.setPasscodeIcon(name: "eye", textField: textField)
            PasscodeViewModel.shared.hiddenPwdIcon.addTarget(self, action: #selector(self.showAndHiddenPasscodeAction), for: .touchUpInside)
            textField.rightView = PasscodeViewModel.shared.hiddenPwdIcon
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
                PasscodeViewModel.shared.isHidden = false
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassView" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
        }
    }
    
    
    //    MARK: - IMAGE
    @objc func addImage(){
        showImageAlert(imagePicker: imagePicker)
    }
    
    
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

        var imgUrl: URL
        if #available(iOS 11.0, *) {
            imgUrl = info[UIImagePickerController.InfoKey.imageURL] as! URL
        } else {
            imgUrl = info[UIImagePickerController.InfoKey.referenceURL] as! URL
        }
        
        let imgName = imgUrl.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let localPath = documentDirectory?.appending(imgName)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let data = image.pngData()! as NSData
        data.write(toFile: localPath!, atomically: true)
        let photoURL = URL.init(fileURLWithPath: localPath!)//NSURL(fileURLWithPath: localPath!)
        AttachmentViewModel.shared.stringImageURL = "\(photoURL)"
        
        let types = AttachmentViewModel.shared.stringImageURL.components(separatedBy: ".")
        let noteID = CreateNoteViewModel.shared.createUniqueNoteDocID(username: NoteViewModel.shared.username!, uniqueID: uniqueID)
        imageID += 1
        let imageName = noteID + String(imageID)
        let name = imageName + ".\(types[1])"
        
        AttachmentViewModel.shared.imageLink = (username: NoteViewModel.shared.username! , noteID: noteID, imageName: name)
        FireBaseProxy.shared.uploadImage(urlImgStr: photoURL,username: NoteViewModel.shared.username!, noteID: noteID, imageName: name)

        if let possibleImage = info[.editedImage] as? UIImage {
            AttachmentViewModel.shared.pickedImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            AttachmentViewModel.shared.pickedImage = possibleImage
        } else {
            return
        }
        AttachmentViewModel.shared.addImage(desTextView: desTextView)
    }

    
    
    
}










