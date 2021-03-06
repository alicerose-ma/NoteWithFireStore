//
//  CreateNoteViewController.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit
import Speech
import SCLAlertView

public enum InputPasscodeCase: String {
    case editPasscode
    case unlockNote
}

class CreateNoteViewController: UIViewController, SetPasscodeDelegate, IsEditingDelegate ,Alertable, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate  {
    
    func sendBackNoteID(noteID: Int) {
        let documentID =  NoteViewModel.shared.username! + "note" + String(noteID)
        FireBaseProxy.shared.updateIsEditing(documentID: documentID, isEditing: true)
    }
    var imageID: Int = -1
    
    var uniqueID: Int = 0
    var hasLock: Bool = false
    var lockStatus: Bool = false
    var isRecord: Bool = false
    var isDelegate: Bool = false
    var isShared: Bool = false
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var lockStatusBtn = UIBarButtonItem()
    var unlockStatusBtn = UIBarButtonItem()
    var voiceBtn = UIBarButtonItem()
    var imageBtn = UIBarButtonItem()
    var userShareBtn = UIBarButtonItem()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBarUI()
        setupDelegate()
        VoiceViewModel.shared.voiceSetup()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
        registerForKeyboardNotifications()
        setupTextViewWithDoneBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
        checkIfDisableShareBtn()
    }
    
    func checkIfDisableShareBtn() {
        let numberOfUsers = SharedNoteViewModel.shared.sharedUsers.count
        if numberOfUsers == 0 {
            isShared = false
            if !titleTextField.text!.isEmpty || !desTextView.text!.isEmpty {
                if self.hasLock == true {
                    self.userShareBtn.isEnabled = false
                    print("has Lock")
                    
                } else {
                    self.userShareBtn.isEnabled = true
                }
                insertLockForNoteBtn.isEnabled = true
            } else {
                insertLockForNoteBtn.isEnabled = false
                userShareBtn.isEnabled = false
            }
        } else {
            isShared = true
            insertLockForNoteBtn.isEnabled = false
            userShareBtn.isEnabled = true
        }

        navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn, self.voiceBtn, self.userShareBtn, self.unlockStatusBtn]
    }
    
    
    //    save note when click back
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VoiceViewModel.shared.stopRecording()
        deregisterFromKeyboardNotifications()
        saveNote()
    }
    
    
    func saveNote(){
        let title = titleTextField.text!
        var description = desTextView.text!
        description  = description.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
        let sharedUsers = SharedNoteViewModel.shared.sharedUsers
        let email = NoteViewModel.shared.username!
        let lastTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        let noteID = CreateNoteViewModel.shared.createUniqueNoteDocID(username: NoteViewModel.shared.username!, uniqueID: uniqueID)
        var note = NoteData(id: uniqueID, email: email, title: title, des: description, isLocked: lockStatus, isEditing: false, imageIDMax: imageID, sharedUsers: sharedUsers, imagePosition: [], imageURL: [], lastUpdateTime: lastTime,
                            lastUpdateUser: email)

        
        if !title.isEmpty && !desTextView.attributedText.string.isEmpty  {
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        } else if title.isEmpty && !desTextView.attributedText.string.isEmpty {
            note.title = "Undefined title"
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        } else if !title.isEmpty && desTextView.attributedText.string.isEmpty {
            note.des = "No description"
            CreateNoteViewModel.shared.addNewNote(documentID: noteID, newNote: note)
        } else {
            NoteViewModel.shared.deleteNote(uniqueID: uniqueID)
            SharedNoteViewModel.shared.deleteOneNoteForAllSharedUsers(uniqueID: uniqueID)
        }
        
        SharedNoteViewModel.shared.sharedUsers = []
        imageID = -1
    }
    
    
    //  MARK: -  TEXT DESCRIBED FROM VOICE
    @objc func voice(){
        VoiceViewModel.shared.clickRecordBtn(titleTextField: titleTextField, desTextView: desTextView, viewController: self)
        if isRecord {
            insertLockForNoteBtn.isEnabled = true
            userShareBtn.isEnabled = true
            changeNavButtonItemForIOS12AndIOS13(name: "mic")
            
        } else {
            insertLockForNoteBtn.isEnabled = false
            userShareBtn.isEnabled = false
            if #available(iOS 13.0, *) {
                voiceBtn.image = UIImage(systemName: "mic.slash")
            } else {
                voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "micSlash", action:  #selector(self.voice)))
            }
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,userShareBtn]
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
                self.navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn,self.voiceBtn, self.userShareBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                if self.titleTextField.text!.isEmpty && self.desTextView.text!.isEmpty {
                    self.showErrorWithoutAction(title: "Add lock failed", message: "Title and description can not both empty")
                } else {
                    SetPasscodeViewModel.shared.getUserPasscode(completion: { (passcode, hint) in
                        if passcode == "" {
                            self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
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
        insertLockForNoteBtn.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,userShareBtn,lockStatusBtn]
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
            PasscodeShowOrHideHelper.shared.textField = textField
            PasscodeShowOrHideHelper.shared.setupPasswordIcon(color: .black)
            
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
        print("Add Lock 1111111111")
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,userShareBtn,unlockStatusBtn]
    }
    
    
    //  MARK: -  SEGUE
    @objc func shareNote() {
        self.performSegue(withIdentifier: "ShowShareSettingFromCreate", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassView" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
        }
        
        if segue.identifier == "ShowShareSettingFromCreate" {
            let destinationVC  = segue.destination as! ShareSettingViewController
            destinationVC.isEditingDelegate = self
            destinationVC.noteID = uniqueID
        }
    }
}


extension CreateNoteViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //    MARK: - setup UI
    func setupDelegate(){
        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        desTextView.delegate = self
    }
    
    func setUpNavBarItem() {
        if #available(iOS 13.0, *) {
            insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "lock.shield"), style: .plain, target: self, action: #selector(self.addOrRemoveLock))
            lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
            unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
            voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
            userShareBtn = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus.fill"), style: .plain, target: self, action: #selector(self.shareNote))
        } else {
            insertLockForNoteBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "security", action:  #selector(self.addOrRemoveLock)))
            lockStatusBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "lock", action:  #selector(self.lockOFF)))
            unlockStatusBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "lockOpen", action:  #selector(self.lockON)))
            voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "mic", action:  #selector(self.voice)))
            userShareBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "userPlus", action:  #selector(self.shareNote)))
        }
        
    }
    
    func setupNavBarUI() {
        setUpNavBarItem()
        lockView.isHidden = true
        voiceBtn.isEnabled = true
        desTextView.autocorrectionType = .no
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,userShareBtn]
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
    
    @objc func doneBtnAction() {
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
    
    
    
    //    MARK: CHECK CONTENT IS EMPTY & SHOW/HIDE USER/LOCK BUTTONS
    //    check TextField and TextView empty
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
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn, userShareBtn]
        }
    }
    
    
    // MARK: SWITCH BETWEEN TEXTFIELD AND TEXTVIEW
    //    switch between textfield and textview => stop record
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switchBetweenTextFieldAndTextView()
    }
    
    //     image only add in textview
    func textViewDidBeginEditing(_ textView: UITextView) {
        switchBetweenTextFieldAndTextView()
    }
    
    func switchBetweenTextFieldAndTextView() {
        VoiceViewModel.shared.stopRecording()
        isRecord = false
        hasLock = false
        checkIfDisableShareBtn()
        changeNavButtonItemForIOS12AndIOS13(name: "mic")
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,userShareBtn]
    }
    
    func changeNavButtonItemForIOS12AndIOS13(name: String){
        if #available(iOS 13.0, *) {
            voiceBtn.image = UIImage(systemName: name)
        } else {
            voiceBtn = UIBarButtonItem(customView: UIImageIO12And13Helper.shared.createBarButtonItem(name: name, action:  #selector(self.voice)))
            if hasLock {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,userShareBtn,unlockStatusBtn]
            } else {
                navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,userShareBtn]
            }
        }
        
    }
}


