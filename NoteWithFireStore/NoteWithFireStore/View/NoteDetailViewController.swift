//
//  AddNewNoteViewController.swift
//  note
//
//  Created by Ma Alice on 1/21/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController, SetPasscodeDelegate, Alertable,  UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imagePicker = UIImagePickerController()
    var uniqueID = -1
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var lockStatusBtn = UIBarButtonItem()
    var unlockStatusBtn = UIBarButtonItem()
    var voiceBtn = UIBarButtonItem()
    var imageBtn = UIBarButtonItem()
    var userShareBtn = UIBarButtonItem()
    
    var hasLock: Bool = false
    var lockStatus: Bool = false
    var isRecord: Bool = false
    var isShared: Bool = false
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBarItem()
        setupDelegate()
        VoiceViewModel.shared.voiceSetup()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
        registerForKeyboardNotifications()
        setupTextViewWithDoneBtn()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBarUI()
        checkIfDisableShareBtn()
        getNoteDetail()
    }
    
    func checkIfDisableShareBtn() {
        SharedNoteViewModel.shared.getSharedUser(id: uniqueID, completion: { sharedUserList in
            SharedNoteViewModel.shared.sharedUsers = sharedUserList
            let numberOfUsers = SharedNoteViewModel.shared.sharedUsers.count
            if numberOfUsers == 0 {
                if self.hasLock == true {
                    self.userShareBtn.isEnabled = false
                    self.insertLockForNoteBtn.isEnabled = false
                } else {
                    self.userShareBtn.isEnabled = true
                    self.insertLockForNoteBtn.isEnabled = true
                }
                self.isShared = false

            } else {
                self.isShared = true
                self.insertLockForNoteBtn.isEnabled = false
                self.userShareBtn.isEnabled = true
            }
        })
    }
    
    func getNoteDetail() {
        NoteDetailViewModel.shared.getNoteByID(id: uniqueID, completion: { notes in
            for note in notes {
                self.titleTextField.text = note.title
                self.desTextView.text = note.des
                
                
                AttachmentViewModel.shared.oldPosition = note.imagePosition
                AttachmentViewModel.shared.oldURL = note.imageURL
                AttachmentViewModel.shared.imageIDMax = note.imageIDMax
                
                SharedNoteViewModel.shared.sharedUsers = note.sharedUsers
                
                var attributedString = NSMutableAttributedString()
                for (index, position) in note.imagePosition.enumerated() {
                    if let newPosition = self.desTextView.position(from: self.desTextView.beginningOfDocument, offset: position) {
                        self.desTextView.selectedTextRange = self.desTextView.textRange(from: newPosition, to: newPosition)
                        attributedString = NSMutableAttributedString(attributedString: self.desTextView.attributedText)
                        
                        let textAttachment = NSTextAttachment()
                        do {
                            let imageData = try Data(contentsOf: URL(string: note.imageURL[index])!)
                            let image = UIImage(data: imageData)!
                            textAttachment.image = image
                            let oldWidth = textAttachment.image!.size.width;
                            let scaleFactor = oldWidth / (self.desTextView.frame.size.width - 10);
                            textAttachment.image = UIImage(cgImage:  textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
                            let attrStringWithImage = NSMutableAttributedString(attachment: textAttachment)
                            attributedString.replaceCharacters(in: NSMakeRange(position, 1), with: attrStringWithImage)
                        } catch {
                            print("Err")
                        }
                        self.desTextView.attributedText = attributedString;
                    }
                }
            }
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VoiceViewModel.shared.stopRecording()
        deregisterFromKeyboardNotifications()
        saveNote()
    }
    
    func saveNote() {
        let title = titleTextField.text!
            var description = desTextView.text!
            description  = description.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
            
            let imagePosition = AttachmentViewModel.shared.oldPosition
            let imageURL = AttachmentViewModel.shared.oldURL
            let imageIDMax = AttachmentViewModel.shared.imageIDMax
            
            let sharedUsers = SharedNoteViewModel.shared.sharedUsers
            
            var note = NoteData(id: uniqueID, email:NoteDetailViewModel.shared .username!, title: title, des: description, isLocked: lockStatus, imageIDMax: imageIDMax, sharedUsers: sharedUsers ,imagePosition: imagePosition, imageURL: imageURL ) //create a new note model with lock
            
            if !title.isEmpty && !desTextView.attributedText.string.isEmpty  {
                NoteDetailViewModel.shared.editNote(uniqueID: uniqueID, newNote: note)
            } else if title.isEmpty && !desTextView.attributedText.string.isEmpty {
                note.title = "Undefined title"
                NoteDetailViewModel.shared.editNote(uniqueID: uniqueID, newNote: note)
            } else if !title.isEmpty && desTextView.attributedText.string.isEmpty {
                note.des = "No description"
                NoteDetailViewModel.shared.editNote(uniqueID: uniqueID, newNote: note)
            } else {
                NoteViewModel.shared.deleteNote(uniqueID: uniqueID)
                SharedNoteViewModel.shared.deleteOneNoteForAllSharedUsers(uniqueID: uniqueID)
            }
            
            SharedNoteViewModel.shared.sharedUsers = []
    }
    
    //  MARK: -  TEXT DESCRIBED FROM VOICE
    @objc func voice(){
        VoiceViewModel.shared.clickRecordBtn(titleTextField: titleTextField, desTextView: desTextView, viewController: self)
        if isRecord {
            imageBtn.isEnabled = false
            insertLockForNoteBtn.isEnabled = true
            userShareBtn.isEnabled = true
            changeNavButtonItemForIOS12AndIOS13(name: "mic")
        } else {
            imageBtn.isEnabled = false
            insertLockForNoteBtn.isEnabled = false
            userShareBtn.isEnabled = false
            if #available(iOS 13.0, *) {
                voiceBtn.image = UIImage(systemName: "mic.slash")
            } else {
                voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "micSlash", action:  #selector(self.voice)))
            }
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,userShareBtn]
        }
        isRecord = !isRecord
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
                self.userShareBtn.isEnabled = true
                self.navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn,self.voiceBtn, self.imageBtn, self.userShareBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                if self.titleTextField.text!.isEmpty && self.desTextView.text!.isEmpty {
                    self.showErrorWithoutAction(title: "Add lock failed", message: "Title and description can not both empty")
                } else {
                    SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint) in
                        if passcode == "" {
                            self.performSegue(withIdentifier: "ShowSetPassViewFromEdit", sender: self)
                        } else {
//                            self.hasLock = true
                            self.addLockIconToNavBar()
                        }
                    })
                }
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
        if self.titleTextField.text!.isEmpty && self.desTextView.text!.isEmpty {
            self.showErrorWithoutAction(title: "Add lock failed", message: "Title and description can not both empty")
        } else {
            VoiceViewModel.shared.stopRecording()
            lockStatus = true
            setupUILockON()
        }
    }
    
    func setupUILockON() {
        if #available(iOS 13.0, *) {
            voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
        } else {
            voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "mic", action:  #selector(self.voice)))
        }
        view.endEditing(true)
        lockView.isHidden = false
        voiceBtn.isEnabled = false
        userShareBtn.isEnabled = false
        imageBtn.isEnabled = false
        insertLockForNoteBtn.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,userShareBtn,lockStatusBtn]
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
        var message = ""
        switch NoteViewModel.shared.enterPasscodeCount {
        case let x where x == 0:
            message = ""
        case let x where x >= 1 && x < 3:
            message = "Wrong passcode, try again"
        case let x where x >= 3:
            message = "Wrong passcode, try again \nHint: \n\(hint)"
        default:
            print("this is impossible")
        }
        alert = UIAlertController(title: "Enter Passcode", message: message, preferredStyle: UIAlertController.Style.alert)
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
                        self.performSegue(withIdentifier: "ShowSetPassViewFromEdit", sender: self)
                    case .unlockNote:
                        self.lockStatus = false
                        self.setupUIWhenLockOFF()
                    }
                } else {
                    NoteViewModel.shared.enterPasscodeCount += 1
                    self.enterPasscodeAlert(passcode: passcode, hint: hint, passcodeCase: passcodeCase)
                }
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //    set up UI when note is unlock
    func setupUIWhenLockOFF(){
        lockView.isHidden = true
        voiceBtn.isEnabled = true
        insertLockForNoteBtn.isEnabled = true
        addLockIconToNavBar()
    }
    
    //  delegate to add lock status for 1st time create passcode
    func addLockIconToNavBar() {
        hasLock = true
        userShareBtn.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,userShareBtn,unlockStatusBtn]
    }
    
    
    
    //    MARK: SEGUE
    @objc func shareNote() {
        self.performSegue(withIdentifier: "ShowShareSettingFromEdit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassViewFromEdit" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
        }
        if segue.identifier == "ShowShareSettingFromEdit" {
            let destinationVC  = segue.destination as! ShareSettingViewController
            destinationVC.noteID = uniqueID
        }
    }
    
    
    //    MARK: - IMAGE
    @objc func addImage(){
        print("click add image")
        showImageAlert(imagePicker: imagePicker)
    }
    
}

extension NoteDetailViewController {
    //    MARK: - setup UI
    func setupDelegate(){
        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
            userShareBtn = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus.fill"), style: .plain, target: self, action: #selector(self.shareNote))
        } else {
            insertLockForNoteBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "security", action:  #selector(self.addOrRemoveLock)))
            lockStatusBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "lock", action:  #selector(self.lockOFF)))
            unlockStatusBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "lockOpen", action:  #selector(self.lockON)))
            voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "mic", action:  #selector(self.voice)))
            imageBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "photo", action:  #selector(self.addImage)))
            userShareBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "userPlus", action:  #selector(self.addImage)))
        }
        
    }
    
    func setupNavBarUI() {
        if lockStatus == true {
            lockView.isHidden = false
            hasLock = true
            voiceBtn.isEnabled = false
            imageBtn.isEnabled = false
            userShareBtn.isEnabled = false
            insertLockForNoteBtn.isEnabled = false
            desTextView.autocorrectionType = .no
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn, voiceBtn ,imageBtn,userShareBtn,lockStatusBtn]
        } else {
            lockView.isHidden = true
            voiceBtn.isEnabled = true
            imageBtn.isEnabled = true
            userShareBtn.isEnabled = true
            insertLockForNoteBtn.isEnabled = true
            desTextView.autocorrectionType = .no
            titleTextField.becomeFirstResponder()
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,userShareBtn]
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    //MARK: - AUTO KEYBOARD FOR TEXTVIEW
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name:  UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name:  UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 20, right: 0.0)
        
        desTextView.scrollIndicatorInsets = contentInsets
        desTextView.contentInset = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        desTextView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        desTextView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.view.endEditing(true)
    }
    
    
    //      set up textview with done button to dimiss the keyboard
    func setupTextViewWithDoneBtn() {
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.size.width, height: 30)))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnAction))
        barButton.tintColor = .blue
        toolBar.setItems([flexible, barButton], animated: false)
        desTextView.inputAccessoryView = toolBar
    }
    
    @objc func doneBtnAction() {
        self.view.endEditing(true)
    }
    
    //    MARK: CHECK CONTENT IS EMPTY & SHOW/HIDE USER/LOCK BUTTONS
    func textViewDidChange(_ textView: UITextView) {
        changeContent()
    }
    
    @objc func textFieldDidChange() {
        changeContent()
    }
    
    func changeContent(){
        if !titleTextField.text!.isEmpty || !desTextView.text.isEmpty{
            if isShared {
                insertLockForNoteBtn.isEnabled = false
            } else {
                insertLockForNoteBtn.isEnabled = true
            }
            if hasLock{
                userShareBtn.isEnabled = false
            } else {
                userShareBtn.isEnabled = true
            }
        }else {
            hasLock = false
            insertLockForNoteBtn.isEnabled = false
            userShareBtn.isEnabled = false
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn, userShareBtn]
        }
    }
    
    // MARK: SWITCH BETWEEN TEXTFIELD AND TEXTVIEW
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
        isRecord = false
        changeNavButtonItemForIOS12AndIOS13(name: "mic")
    }
    
    func changeNavButtonItemForIOS12AndIOS13(name: String){
        if #available(iOS 13.0, *) {
            voiceBtn.image = UIImage(systemName: name)
        } else {
            voiceBtn = UIBarButtonItem(customView: UIImageIO12And13Helper.shared.createBarButtonItem(name: name, action:  #selector(self.voice)))
            if hasLock {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,userShareBtn,unlockStatusBtn]
            } else {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn,userShareBtn]
            }
        }
        
    }
}




//func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//    var cursorPosition = 0
//    if text.isBackspace {
//        if let selectedRange = desTextView.selectedTextRange {
//            cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start) - 1
//        }
//        print("cursor REMOVE")
//        print(cursorPosition)
//
//        var deleteImage = false
//        let imagePositionArr = AttachmentViewModel.shared.oldPosition
//        for (index, position) in imagePositionArr.enumerated() {
//            if cursorPosition < position  {
//                if !deleteImage {
//                    AttachmentViewModel.shared.oldPosition[index] = position - 1
//                } else {
//                    AttachmentViewModel.shared.oldPosition[index-1] = position - 1
//                }
//            } else if cursorPosition == position {
//                deleteImage = true
//                AttachmentViewModel.shared.oldPosition.remove(at: index)
//                AttachmentViewModel.shared.oldURL.remove(at: index)
//            }
//        }
//    } else {
//        if let selectedRange = desTextView.selectedTextRange {
//            cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start) + 1
//        }
//        print("cursor ADD")
//        print(cursorPosition)
//
//        let imagePositionArr = AttachmentViewModel.shared.oldPosition
//        for (index, position) in imagePositionArr.enumerated() {
//            if cursorPosition <= position + 1 {
//                AttachmentViewModel.shared.oldPosition[index] = position + 1
//            }
//        }
//        print("cursor Array OLD")
//        print(AttachmentViewModel.shared.oldPosition)
//
//    }
//    return true
//}


//
//
//
//func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//    self.dismiss(animated: true, completion: nil)
//
//    if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
//        let imgName = imgUrl.lastPathComponent
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
//        let localPath = documentDirectory?.appending(imgName)
//
//        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        let data = image.pngData()! as NSData
//        data.write(toFile: localPath!, atomically: true)
//        let photoURL = URL.init(fileURLWithPath: localPath!)//NSURL(fileURLWithPath: localPath!)
//        AttachmentViewModel.shared.stringImageURL = "\(photoURL)"
//
//
//        let types = AttachmentViewModel.shared.stringImageURL.components(separatedBy: ".")
//        let noteID = NoteDetailViewModel.shared.username! + "note" + String(uniqueID)
//        let imageName = noteID + String(AttachmentViewModel.shared.imageIDMax + 1)
//        let name = imageName + ".\(types[1])"
//
//        AttachmentViewModel.shared.imageEditLink = (username: CreateNoteViewModel.shared.username! , noteID: noteID, imageName: name)
//        FireBaseProxy.shared.uploadImage(urlImgStr: photoURL,username: CreateNoteViewModel.shared.username!, noteID: noteID, imageName: name)
//    }
//
//    if let possibleImage = info[.editedImage] as? UIImage {
//        AttachmentViewModel.shared.pickedImage = possibleImage
//    } else if let possibleImage = info[.originalImage] as? UIImage {
//        AttachmentViewModel.shared.pickedImage = possibleImage
//    } else {
//        return
//    }
//    AttachmentViewModel.shared.editImage(desTextView: desTextView)
//}

