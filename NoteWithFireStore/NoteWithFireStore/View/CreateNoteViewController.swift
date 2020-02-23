//
//  CreateNoteViewController.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class CreateNoteViewController: UIViewController, SetPasscodeDelegate {
    
    var uniqueID: Int = 0
    var hasLock: Bool = false
    var lockStatus: Bool = false
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var createNoteViewModel = CreateNoteViewModel()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        lockView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(addOrRemoveLock))
        
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn]
    }
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        let hasPasscode = UserDefaults.standard.string(forKey: createNoteViewModel.username!)!
        enterPasscodeToUnLock(passcode: hasPasscode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let title = titleTextField.text!
        let description = desTextView.text!
        
        let noteID = createNoteViewModel.createUniqueNoteDocID(username: createNoteViewModel.username!, uniqueID: uniqueID)
        let note = NoteData(username: createNoteViewModel.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus) //create a new note model with lock
        
        if !title.isEmpty || !description.isEmpty{
            createNoteViewModel.addNewNote(documentID: noteID, newNote: note)
        }
    }
    
    //    delegate to add lock status
    func addLockStatus() {
        let unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
        navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn, unlockStatusBtn]
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
                let hasPasscode = UserDefaults.standard.string(forKey: self.createNoteViewModel.username!)
                if hasPasscode == nil {
                    self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                } else {
                    self.addLockStatus()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Edit Passcode", style: .destructive, handler: { (_) in
                UserDefaults.standard.removeObject(forKey: self.createNoteViewModel.username!)
                print("removed")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @objc func lockON(){
        lockStatus = true
        let lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
        navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn, lockStatusBtn]
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
        
        print("status = \(lockStatus)")
        lockView.isHidden = false
    }
    
    @objc func lockOFF() {
        let hasPasscode = UserDefaults.standard.string(forKey: createNoteViewModel.username!)!
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
                    print("OK")
                    self.lockStatus = false
                    self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
                    self.addLockStatus()
                    
                    print("status = \(self.lockStatus)")
                    self.lockView.isHidden = true
                    
                } else {
                    self.createNoteViewModel.showAlert(title: "Passcode Alert", message: "Incorrect")
                }
            }})
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassView" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
        }
    }
    
    
    
    public func showAlert(title: String, message: String) {
          let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        self.present(alert, animated: true)
      }
}


