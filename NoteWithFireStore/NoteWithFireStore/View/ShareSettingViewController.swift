//
//  ShareSettingViewController.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/30/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class ShareSettingViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, Alertable {
    
    var noteID: Int = -1
    var isEdit: Bool = false
    
    @IBOutlet weak var sharedUserTableView: UITableView!
    @IBOutlet weak var shareEmailTextField: UITextField!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var viewBtn: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(noteID)
        sharedUserTableView.dataSource = self
        sharedUserTableView.delegate = self
        
        viewBtn.isSelected = true
        editBtn.isSelected = false
    }
    
    @IBAction func clickView(_ sender: Any) {
        viewBtn.isSelected = true
        editBtn.isSelected = false
        isEdit = false
    }
    
    @IBAction func clickEdit(_ sender: Any) {
        viewBtn.isSelected = false
        editBtn.isSelected = true
        isEdit = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        loadSharedUsers()
    }
    
    
    func loadSharedUsers(){
        let alert = UIAlertController(title: "Please wait.." , message: nil, preferredStyle: .alert)
        waitAlert(alert: alert)
        SharedNoteViewModel.shared.getSharedUser(id: self.noteID, completion: { sharedUserList in
            SharedNoteViewModel.shared.sharedUsers = sharedUserList
            print("user share = \(sharedUserList)")
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: {
                    self.sharedUserTableView.reloadData()
                })
            }
        })
    }
    
    @IBAction func addPeopleBtn(_ sender: Any) {        
        let userToShare = shareEmailTextField.text!
        if userToShare != "" {
            if userToShare != SharedNoteViewModel.shared.username! {
                SharedNoteViewModel.shared.updateSharedNoteForSingleUser(userToShare: userToShare, noteToShare: noteID, isEdit: isEdit, completion: { isShared in
                    if isShared {
                        SharedNoteViewModel.shared.updateSharedUserForSingleNote(username: NoteViewModel.shared.username!, id: self.noteID, userToShare: userToShare, isEdit: self.isEdit, completion:{ isUpdated in
                            if isUpdated {
                                self.loadSharedUsers()
                                self.shareEmailTextField.text = ""
                            } else {
                                self.showResultShareAlert(title: "Share Result", message: "Username exists")
                            }
                        })
                    } else {
                        self.showResultShareAlert(title: "Share Result", message: "Username is invalid")
                    }
                })
            } else {
                self.showResultShareAlert(title: "Share Result", message: "Can not share to yourself")
            }
        }
    }
    
    @IBAction func stopShareBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Shared note stop" , message: "Stop share note with all people?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            SharedNoteViewModel.shared.deleteOneNoteForAllSharedUsers(uniqueID: self.noteID)
            SharedNoteViewModel.shared.deleteAllSharedUsersForOneNote(uniqueID: self.noteID)
            self.loadSharedUsers()
        }))
        self.present(alert, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedNoteViewModel.shared.sharedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  sharedUserTableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let emailAndMode = SharedNoteViewModel.shared.sharedUsers[indexPath.row].components(separatedBy: "mode")
        cell.textLabel?.text = emailAndMode[0]
        cell.detailTextLabel?.text = emailAndMode[1]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // DELETE ACTION
        let deleteAction =  UITableViewRowAction(style: .destructive, title: "Delete", handler: {(action, indexPath)  in
            let singleSharedUser = SharedNoteViewModel.shared.sharedUsers[indexPath.row]
            let emailAndMode = singleSharedUser.components(separatedBy: "mode")
            SharedNoteViewModel.shared.deleteOneNoteForOneUser(userToShare: emailAndMode[0], uniqueID: self.noteID, mode: emailAndMode[1])
            SharedNoteViewModel.shared.deleteOneUserForOneNote(id: self.noteID, noteNameWitEmail: singleSharedUser, completion: {
                deleted in
                if deleted {
                    self.loadSharedUsers()
                }
            })
        })
        
        // CHANCE MODE ACTION
        let shareAction =  UITableViewRowAction(style: .normal, title: "Change mode", handler: {(action, indexPath)  in
            let singleSharedUser = SharedNoteViewModel.shared.sharedUsers[indexPath.row]
            let emailAndMode = singleSharedUser.components(separatedBy: "mode")
            SharedNoteViewModel.shared.changeModeOneNoteForOneUser(userToShare: emailAndMode[0], uniqueID: self.noteID, mode: emailAndMode[1])
            SharedNoteViewModel.shared.changeModeOneUserForOneNote(id: self.noteID, userToShare: emailAndMode[0], mode: emailAndMode[1], completion: { updateModeSuccess in
                if updateModeSuccess {
                    self.loadSharedUsers()
                }
                
            })
        })
        
        shareAction.backgroundColor = .blue

        return [deleteAction, shareAction]
    }
    
    
    
    
    func showResultShareAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }

}
