//
//  CreateNoteViewController.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit
import Speech

public enum InputPasscodeCase: String {
    case editPasscode
    case unlockNote
}

class CreateNoteViewController: UIViewController, SetPasscodeDelegate, Alertable, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var imagePicker = UIImagePickerController()
    var imageID: Int = -1
    
    var uniqueID: Int = 0
    var hasLock: Bool = false
    var lockStatus: Bool = false
    var isRecord: Bool = false
    var isDelegate: Bool = false
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var lockStatusBtn = UIBarButtonItem()
    var unlockStatusBtn = UIBarButtonItem()
    var voiceBtn = UIBarButtonItem()
    var imageBtn = UIBarButtonItem()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
         return true
     }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBarUI()
        setupDelegate()
        VoiceViewModel.shared.voiceSetup()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
    }
    
    
    //    MARK: - setup UI
    func setupDelegate(){
        titleTextField.delegate = self
        desTextView.delegate = self
        imagePicker.delegate = self
    }
    
    func setUpNavBarItem() {
        if #available(iOS 13.0, *) {
            insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "lock.shield"), style: .plain, target: self, action: #selector(self.addOrRemoveLock))
            lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
            unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
            voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
            imageBtn = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(self.addImage))
        } else {
            insertLockForNoteBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "security", action:  #selector(self.addOrRemoveLock)))
            lockStatusBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "lock", action:  #selector(self.lockOFF)))
            unlockStatusBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "lockOpen", action:  #selector(self.lockON)))
            voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "mic", action:  #selector(self.voice)))
            imageBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "photo", action:  #selector(self.addImage)))
        }
        
    }
    
    func setupNavBarUI() {
        setUpNavBarItem()
        lockView.isHidden = true
        voiceBtn.isEnabled = false
        imageBtn.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
        self.tabBarController?.tabBar.isHidden = true
    }
    
//    save note when click back
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VoiceViewModel.shared.stopRecording()
        let title = titleTextField.text!
        let description = desTextView.attributedText.string
        let imagePosition = AttachmentViewModel.shared.newImagePosition
        let imageURL = AttachmentViewModel.shared.newImageURL
        
        let noteID = CreateNoteViewModel.shared.createUniqueNoteDocID(username: NoteViewModel.shared.username!, uniqueID: uniqueID)
        var note = NoteData(id: uniqueID, username: NoteViewModel.shared.username!, title: title, des: description, isLocked: lockStatus, imageIDMax: imageID, sharedUsers: [], imagePosition: imagePosition, imageURL: imageURL )
        
        if !title.isEmpty && !desTextView.attributedText.string.isEmpty  {
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        } else if title.isEmpty && !desTextView.attributedText.string.isEmpty {
            note.title = "Undefined title"
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        } else if !title.isEmpty && desTextView.attributedText.string.isEmpty {
            note.des = "No description"
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
            imageBtn.isEnabled = true
            insertLockForNoteBtn.isEnabled = true
            changeNavButtonItemForIOS12AndIOS13(name: "mic")
            
        } else {
            imageBtn.isEnabled = false
            insertLockForNoteBtn.isEnabled = false
            if #available(iOS 13.0, *) {
                voiceBtn.image = UIImage(systemName: "mic.slash")
            } else {
                voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "micSlash", action:  #selector(self.voice)))
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
            }
        }
        isRecord = !isRecord
    }
    
    //    switch between textfield and textview => stop record
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switchBetweenTextFieldAndTextView()
        imageBtn.isEnabled = false
    }
    
    //     image only add in textview
    func textViewDidBeginEditing(_ textView: UITextView) {
        switchBetweenTextFieldAndTextView()
        imageBtn.isEnabled = true
    }
    
    func switchBetweenTextFieldAndTextView() {
        VoiceViewModel.shared.stopRecording()
        insertLockForNoteBtn.isEnabled = true
        voiceBtn.isEnabled = true
        isRecord = false
        changeNavButtonItemForIOS12AndIOS13(name: "mic")
    }
    
    func changeNavButtonItemForIOS12AndIOS13(name: String){
        if #available(iOS 13.0, *) {
            voiceBtn.image = UIImage(systemName: name)
        } else {
            voiceBtn = UIBarButtonItem(customView: UIImageIO12And13Helper.shared.createBarButtonItem(name: name, action:  #selector(self.voice)))
            if hasLock {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,unlockStatusBtn]
            } else {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
            }
        }
        
    }
    
    //    MARK: - ADD OR REMOVE LOCK OPTION
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
                SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint) in
                    if passcode == "" {
                        self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                    } else {
                        self.hasLock = true
                        self.addLockIconToNavBar()
                    }
                })
            }))
        }
        
        //      edit passcode action
        SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint)  in
            if passcode != "" {
                alert.addAction(UIAlertAction(title: "Edit Passcode", style: .default, handler: { (_) in
                    SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint) in
                        NoteViewModel.shared.enterPasscodeCount = 0
                        self.enterPasscodeAlert(passcode: passcode, hint: hint, passcodeCase: .editPasscode)
                    })
                }))
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    //    MARK: - NOTE IS LOCKED
    @objc func lockON(){
        VoiceViewModel.shared.stopRecording()
        lockStatus = true
        setupUILockON()
    }
    
    func setupUILockON() {
        if #available(iOS 13.0, *) {
            voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
        } else {
            voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "mic", action:  #selector(self.voice)))
        }
        lockView.isHidden = false
        voiceBtn.isEnabled = false
        imageBtn.isEnabled = false
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,lockStatusBtn]
    }
    
    //    MARK: - NOTE IS UNLOCKED
    @objc func lockOFF() {
        SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint) in
            NoteViewModel.shared.enterPasscodeCount = 0
            self.enterPasscodeAlert(passcode: passcode, hint: hint, passcodeCase: .unlockNote)
        })
    }
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint) in
            NoteViewModel.shared.enterPasscodeCount = 0
            self.enterPasscodeAlert(passcode: passcode, hint: hint, passcodeCase: .unlockNote)
        })
    }
    
    //  MARK: - ENTER PASSCODE TO EDIT PASSCODE AND UNLOCK
    func enterPasscodeAlert(passcode: String, hint: String , passcodeCase: InputPasscodeCase) {
        var alert = UIAlertController()
        if NoteViewModel.shared.enterPasscodeCount >= 3 {
            alert = UIAlertController(title: "Enter Passcode", message: "Hint: \(hint)", preferredStyle: UIAlertController.Style.alert)
        } else {
            alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            textField.isSecureTextEntry = true
            ShowPasscodeViewModel.shared.textField = textField
            ShowPasscodeViewModel.shared.setupPasswordIcon(color: .black)
            
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
                if password == passcode {
                    switch passcodeCase {
                    case .editPasscode:
                        self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                    case .unlockNote:
                        self.lockStatus = false
                        self.setupUIWhenLockOFF()
                    }
                } else {
                    NoteViewModel.shared.enterPasscodeCount += 1
                    self.showWrongPasscodeAlert(title: .passcodeValidation, message: .wrong)
                    self.dismiss(animated: true, completion: {
                        self.enterPasscodeAlert(passcode: passcode, hint: hint, passcodeCase: passcodeCase)
                    })
                   
                }
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //    set up UI when note is unlock
    func setupUIWhenLockOFF(){
        lockView.isHidden = true
        navigationItem.rightBarButtonItems?.first?.isEnabled = true
        addLockIconToNavBar()
    }
    
    //  delegate to add lock status for 1st time create passcode
    func addLockIconToNavBar() {
        hasLock = true
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,unlockStatusBtn]
    }
    
    
    //  MARK: -  SEGUE
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










