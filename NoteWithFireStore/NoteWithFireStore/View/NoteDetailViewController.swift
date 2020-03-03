//
//  AddNewNoteViewController.swift
//  note
//
//  Created by Ma Alice on 1/21/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController, SetPasscodeDelegate, Alertable {
    var uniqueID = 0
    var noteDetailViewModel = NoteDetailViewModel()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var lockStatusBtn = UIBarButtonItem()
    var unlockStatusBtn = UIBarButtonItem()
    
    var hasLock: Bool = false
    var lockStatus: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarItemSetUp()
        noteDetailViewModel.getNoteByID(id: uniqueID, completion: { notes in
            for note in notes {
                self.titleTextField.text = note.title
                self.desTextView.text = note.des
            }
        })
        
        if lockStatus == true {
            lockView.isHidden = false
            hasLock = true
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn, lockStatusBtn]
            navigationItem.rightBarButtonItems?.first?.isEnabled = false
        } else {
            lockView.isHidden = true
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn]
            
        }
    }
    
    func navBarItemSetUp() {
        insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(addOrRemoveLock))
        lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
        unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let title = titleTextField.text!
        let description = desTextView.text!
        
        if !title.isEmpty || !description.isEmpty {
            let note = NoteData(username: noteDetailViewModel.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus) //create a new note model with lock
            noteDetailViewModel.editNote(uniqueID: uniqueID, newNote: note)
        }
    }
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        self.noteDetailViewModel.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
    }
    
    //    delegate to add lock status
    func addLockIconToNavBar() {
        hasLock = true
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,unlockStatusBtn]
    }
    
    @objc func addOrRemoveLock() {
        showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: hasLock)
    }
    
    func showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: Bool) {
        let alert = UIAlertController(title: "Lock Note", message: "Select Lock Options" , preferredStyle: .actionSheet)
        if hasLock {
            alert.addAction(UIAlertAction(title: "Remove Lock", style: .default, handler: { (_) in
                self.hasLock = false
                self.navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                self.hasLock = true
                self.noteDetailViewModel.getUserPasscode(completion: { passcode in
                    if passcode == "" {
                        self.performSegue(withIdentifier: "ShowSetPassViewFromEdit", sender: self)
                    } else {
                        self.addLockIconToNavBar()
                    }
                })
            }))
        }
        
        self.noteDetailViewModel.getUserPasscode(completion: { passcode in
            if passcode != "" {
                alert.addAction(UIAlertAction(title: "Edit Passcode", style: .default, handler: { (_) in
                    self.noteDetailViewModel.getUserPasscode(completion: { passcode in
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
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,lockStatusBtn]
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
    }
    
    //    note is unlocked
    @objc func lockOFF() {
        self.noteDetailViewModel.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
    }
    
    
    func enterPasscodeAlert(passcode: String, passcodeCase: InputPasscodeCase) {
        let alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
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

