//
//  NoteViewController.swift
//  note
//
//  Created by Ma Alice on 1/20/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit


class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Alertable {
    @IBOutlet weak var noteTableView: UITableView!
    
    var noteList = [NoteData]()
    var noteViewModel =  NoteViewModel()
    var selectedRow: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTableView.dataSource = self
        noteTableView.delegate = self
        self.title = "Notes"
        setupNavUI()
    }
    
    func setupNavUI() {
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        self.navigationItem.rightBarButtonItem = addBtn
        
        let exitBtn = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(exit))
        self.navigationItem.leftBarButtonItem = exitBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didLogin()
    }
    
    //    check if user login before
    func didLogin() {
        let didLogin = noteViewModel.didLogin()
        if didLogin {
            loadNoteList()
        } else {
            self.performSegue(withIdentifier: "ShowLoginView", sender: self)
        }
    }
    
    //    load note list of user
    func loadNoteList() {
        noteViewModel.getNoteList(completion: { notes in
            self.noteList = notes
            DispatchQueue.main.async {
                self.noteTableView.reloadData()
            }
        })
    }
    
    
    @objc func addNote() {
        self.performSegue(withIdentifier: "AddNewNote", sender: self)
    }
    
    @objc func exit() {
        noteViewModel.logOutUser()
        self.performSegue(withIdentifier: "ShowLoginView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  noteTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        
        if (noteList[indexPath.row].isLocked == false ) {
            cell.titleLabel.text = noteList[indexPath.row].title
            cell.desLabel.text = noteList[indexPath.row].des
        } else {
            cell.titleLabel.text = noteList[indexPath.row].title
            cell.desLabel.text = "locked"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditNote", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //    swipe left to delete note
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {(contextualAction, view, boolValue) in
            
            //            check lock status to delete, no lock => delete, locked => input pass to delete
            if (self.noteList[indexPath.row].isLocked == false) {
                self.noteViewModel.deleteNote(uniqueID: self.noteList[indexPath.row].id, completion: { message in
                    print(message)
                })
                self.noteList.remove(at: indexPath.row)
                self.noteTableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                let passcode = UserDefaults.standard.string(forKey: "passcode")
                self.enterPasscodeToDelete(passcode: passcode!, indexPath: indexPath)
            }
            
        })
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    func enterPasscodeToDelete(passcode: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
                print("Your password: \(password)")
                if password == passcode {
                    self.noteViewModel.deleteNote(uniqueID: self.noteList[indexPath.row].id, completion: { message in
                        print(message)
                    })
                    self.noteList.remove(at: indexPath.row)
                    self.noteTableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    print("incorrect passcode")
                    self.showAlert(title: .passcodeValidation, message: .wrong)
                }
            }})
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    //    transfer to other views by identifier
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewNote" {
            let destinationVC  = segue.destination as! CreateNoteViewController
            destinationVC.uniqueID = noteViewModel.createNewUniqueNoteID(noteList: noteList)
        }
        
        if segue.identifier == "EditNote" {
            let destinationVC  = segue.destination as! NoteDetailViewController
            selectedRow = noteTableView.indexPathForSelectedRow!.row
            let uniqueID = noteList[selectedRow].id
            destinationVC.uniqueID = uniqueID
            let lockStatus = noteList[selectedRow].isLocked
            destinationVC.lockStatus = lockStatus
        }
        
        if segue.identifier == "ShowLoginView" {
            _ = segue.destination as! LoginViewController
        }
    }
    
}
