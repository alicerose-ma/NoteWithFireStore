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

class CreateNoteViewController: UIViewController, SetPasscodeDelegate, Alertable, UITextFieldDelegate, UITextViewDelegate  {
    
    @IBOutlet weak var recordOutlet: UIButton!
    var voiceViewModel = VoiceViewModel()
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
    
    var createNoteViewModel = CreateNoteViewModel()
    var setPasscodeViewModel = SetPasscodeViewModel()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        desTextView.delegate = self
        lockView.isHidden = true
        navBarItemSetUp()
        voiceBtn.isEnabled = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,imageBtn]
        voiceViewModel.voiceSetupWithoutRecordBtn()
    }
    
    func navBarItemSetUp() {
        insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(addOrRemoveLock))
        lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
        unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
        voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
        imageBtn = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(self.addImage))
    }
    
    
    @objc func addImage(){
        print("click add image")
        showImageAlert(desTextView: desTextView)
    }
    
    
//    TEXT DESCRIBED FROM VOICE
    @objc func voice(){
        voiceViewModel.clickRecordBtn(titleTextField: titleTextField, desTextView: desTextView)
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
        voiceViewModel.stopRecording()
        voiceBtn.isEnabled = true
        isRecord = false
        voiceBtn.image = UIImage(systemName: "mic")
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        voiceViewModel.stopRecording()
        voiceBtn.isEnabled = true
        isRecord = false
        voiceBtn.image = UIImage(systemName: "mic")
    }
    
    
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        setPasscodeViewModel.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let title = titleTextField.text!
        let description = desTextView.text!
        
        if !title.isEmpty || !description.isEmpty {
            let noteID = createNoteViewModel.createUniqueNoteDocID(username: createNoteViewModel.username!, uniqueID: uniqueID)
            let note = NoteData(username: createNoteViewModel.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus, sharedUsers: []) //create a new note model with lock
            createNoteViewModel.addNewNote(documentID: noteID, newNote: note)
        }
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
                self.navigationItem.rightBarButtonItems = [self.voiceBtn,self.insertLockForNoteBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                self.hasLock = true
                self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
                    if passcode == "" {
                        self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                    } else {
                        self.addLockIconToNavBar()
                    }
                })
            }))
        }
        
        //        edit passcode action
        self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
            if passcode != "" {
                alert.addAction(UIAlertAction(title: "Edit Passcode", style: .default, handler: { (_) in
                    self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
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
        self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
    }
    
    @objc func showAndHiddenPasscodeAction(_ sender: Any) {
        createNoteViewModel.displayPasscode(alert: alert)
    }

    
    //    enter passcode to edit and unlock
    func enterPasscodeAlert(passcode: String, passcodeCase: InputPasscodeCase) {
        alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            textField.isSecureTextEntry = true

            self.createNoteViewModel.setPasscodeIcon(name: "eye", textField: textField)
            self.createNoteViewModel.micStart.addTarget(self, action: #selector(self.showAndHiddenPasscodeAction), for: .touchUpInside)
            textField.rightView = self.createNoteViewModel.micStart
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
                        self.imageBtn.isEnabled = true
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

