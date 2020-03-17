//
//  AddNewNoteViewController.swift
//  note
//
//  Created by Ma Alice on 1/21/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController, SetPasscodeDelegate, Alertable,  UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var recordOutlet: UIButton!
    var voiceViewModel = VoiceViewModel()
    var alert = UIAlertController()
    
    var uniqueID = 0
    var noteDetailViewModel = NoteDetailViewModel()
    var setPasscodeViewModel = SetPasscodeViewModel()
    var createNoteViewModel = CreateNoteViewModel()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var lockStatusBtn = UIBarButtonItem()
    var unlockStatusBtn = UIBarButtonItem()
    var voiceBtn = UIBarButtonItem()
    
    var hasLock: Bool = false
    var lockStatus: Bool = false
    var isRecord: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarItemSetUp()
        titleTextField.delegate = self
        desTextView.delegate = self
        voiceViewModel.voiceSetupWithoutRecordBtn()
        noteDetailViewModel.getNoteByID(id: uniqueID, completion: { notes in
            for note in notes {
                self.titleTextField.text = note.title
                self.desTextView.text = note.des
            }
        })
        
        if lockStatus == true {
            lockView.isHidden = false
            hasLock = true
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn, voiceBtn ,lockStatusBtn]
            navigationItem.rightBarButtonItems?.first?.isEnabled = false
            voiceBtn.isEnabled = false
        } else {
            lockView.isHidden = true
            voiceBtn.isEnabled = false
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn]
            
        }
    }
    
    func navBarItemSetUp() {
        insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(addOrRemoveLock))
        lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
        unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
        voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
    }
    
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
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        voiceViewModel.stopRecording()
        isRecord = false
        voiceBtn.isEnabled = true
        voiceBtn.image = UIImage(systemName: "mic")
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        voiceViewModel.stopRecording()
        isRecord = false
        voiceBtn.isEnabled = true
        voiceBtn.image = UIImage(systemName: "mic")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let title = titleTextField.text!
        let description = desTextView.text!
        
        if !title.isEmpty || !description.isEmpty {
            let note = NoteData(username: noteDetailViewModel.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus, sharedUsers: []) //create a new note model with lock
            noteDetailViewModel.editNote(uniqueID: uniqueID, newNote: note)
        }
    }
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
    }
    
    //    delegate to add lock status
    func addLockIconToNavBar() {
        hasLock = true
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,unlockStatusBtn]
    }
    
    @objc func addOrRemoveLock() {
        showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: hasLock)
    }
    
    func showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: Bool) {
        let alert = UIAlertController(title: "Lock Note", message: "Select Lock Options" , preferredStyle: .actionSheet)
        if hasLock {
            alert.addAction(UIAlertAction(title: "Remove Lock", style: .default, handler: { (_) in
                self.hasLock = false
                self.navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn, self.voiceBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                self.hasLock = true
                self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
                    if passcode == "" {
                        self.performSegue(withIdentifier: "ShowSetPassViewFromEdit", sender: self)
                    } else {
                        self.addLockIconToNavBar()
                    }
                })
            }))
        }
        
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
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,voiceBtn,lockStatusBtn]
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
        voiceBtn.isEnabled = false
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
    
    
    func enterPasscodeAlert(passcode: String, passcodeCase: InputPasscodeCase) {
        alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            textField.isSecureTextEntry = true
            
            self.createNoteViewModel.setPasscodeIcon(name: "eye", textField: textField)
            self.createNoteViewModel.micStart.addTarget(self, action: #selector(self.showAndHiddenPasscodeAction), for: .touchUpInside)
            textField.rightView = self.createNoteViewModel.micStart
            textField.rightViewMode = .always
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in            if let password = self.alert.textFields?.first?.text {
            if password == passcode {
                switch passcodeCase {
                case .editPasscode:
                    self.performSegue(withIdentifier: "ShowSetPassViewFromEdit", sender: self)
                case .unlockNote:
                    self.lockStatus = false
                    self.lockView.isHidden = true
                    self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
                    self.addLockIconToNavBar()
                }
            }else {
                self.showAlert(title: .passcodeValidation, message: .wrong)
            }
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassViewFromEdit" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
        }
    }
}

