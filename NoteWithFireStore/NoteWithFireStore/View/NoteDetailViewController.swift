//
//  AddNewNoteViewController.swift
//  note
//
//  Created by Ma Alice on 1/21/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController, SetPasscodeDelegate , Alertable {
    var uniqueID = 0
    var noteDetailViewModel = NoteDetailViewModel()
    var createNoteViewModel = CreateNoteViewModel()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var hasLock: Bool = false
    var lockStatus: Bool = false
    
    //    setup nav bar and lock view visibility before content view presented
    override func viewWillAppear(_ animated: Bool) {
        insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(addOrRemoveLock))
        
        if lockStatus == true {
            lockView.isHidden = false
            hasLock = true
            let lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn, lockStatusBtn]
            navigationItem.rightBarButtonItems?.first?.isEnabled = false
            
        } else {
            lockView.isHidden = true
            navigationItem.rightBarButtonItems = [insertLockForNoteBtn]
            
        }
    }
    
    //    controller content is created and loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        noteDetailViewModel.getNoteByID(id: uniqueID, completion: { notes in
            for note in notes {
                self.titleTextField.text = note.title
                self.desTextView.text = note.des
                self.lockStatus = note.isLocked
            }
        })
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            
        let title = titleTextField.text!
        let description = desTextView.text!
        
        let note = NoteData(username: createNoteViewModel.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus) //create a new note model with lock
        noteDetailViewModel.editNote(uniqueID: uniqueID, newNote: note)
    }
    
    func addLockStatus() {
        let unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
        navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn, unlockStatusBtn]
    }
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        let hasPasscode = UserDefaults.standard.string(forKey: noteDetailViewModel.username!)!
        enterPasscodeToUnLock(passcode: hasPasscode)
    }
    
    @objc func addOrRemoveLock() {
        showAddOrRemoveLockActionSheet(hasLock: hasLock)
    }
    
    func showAddOrRemoveLockActionSheet(hasLock: Bool) {
        let alert = UIAlertController(title: "Lock Note", message: "Select Lock Options" , preferredStyle: .actionSheet)
        
        if hasLock {
            alert.addAction(UIAlertAction(title: "Remove Lock", style: .default, handler: { (_) in
                self.hasLock = false
                self.navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                self.hasLock = true
                let hasPasscode = UserDefaults.standard.string(forKey: self.noteDetailViewModel.username!)
                if hasPasscode == nil {
                    self.performSegue(withIdentifier: "ShowSetPassViewFromEdit", sender: self)
                } else {
                    self.addLockStatus()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Delete Passcode", style: .destructive, handler: { (_) in
                UserDefaults.standard.removeObject(forKey: self.noteDetailViewModel.username!)
                print("removed")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    
    @objc func lockON(){
        lockStatus = true
        let lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
        navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn, lockStatusBtn]
        lockView.isHidden = false
    }
    
    @objc func lockOFF() {
        let hasPasscode = UserDefaults.standard.string(forKey: noteDetailViewModel.username!)!
        enterPasscodeToUnLock(passcode: hasPasscode)
    }
    
    
    //    enter passcode to unlock note
    func enterPasscodeToUnLock(passcode: String) {
        let alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
                if password == passcode {
                    self.lockStatus = false
                    self.addLockStatus()
                    self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
                    self.lockView.isHidden = true
                    
                } else {
                     self.showAlert(title: "Passcode", message: "The passcode is incorrect")
                }
            }})
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassViewFromEdit" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
            
        }
    }
    
}

