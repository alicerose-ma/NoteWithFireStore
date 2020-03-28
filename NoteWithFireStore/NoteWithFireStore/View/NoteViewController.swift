//
//  NoteViewController.swift
//  note
//
//  Created by Ma Alice on 1/20/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit
import Speech


class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Alertable, UISearchResultsUpdating, UISearchBarDelegate, SFSpeechRecognizerDelegate {
    @IBOutlet weak var noteTableView: UITableView!
    
    //  list of note getting from Firestore
    var allNoteList = [NoteData]()
    var filteredNoteList = [NoteData]()
    var selectedRow: Int = -1 // current row selected in tableview
    
    //
    var alert = UIAlertController()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTableView.dataSource = self
        noteTableView.delegate = self
        self.title = "Notes"
        setupNavUI()
        setupSearchController()
        VoiceViewModel.shared.voiceSetupWithoutRecordBtn()
    }
    
    
    // MARK: - CHECK USER LOGIN BEFORE
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didLogin()
        searchController.searchBar.text = nil
    }
    
    func didLogin() {     //    check if user login before
        let didLogin = NoteViewModel.shared.didLogin()
        if didLogin {
            loadNoteList()
        } else {
            UIView.setAnimationsEnabled(false)
            self.performSegue(withIdentifier: "ShowLoginViewFromYourNote", sender: self)
        }
    }
    
    func loadNoteList() {   //    load note list of user
        NoteViewModel.shared.getNoteList(completion: { notes in
            self.allNoteList = notes
            self.filteredNoteList = notes
            DispatchQueue.main.async {
                self.noteTableView.reloadData()
            }
        })
    }
    
    
    //    MARK: - TABLEVIEW DISPLAY NOTE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNoteList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  noteTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        
        if (filteredNoteList[indexPath.row].isLocked == false) {
            cell.titleLabel.text = filteredNoteList[indexPath.row].title
            
            let attributeData = Data(filteredNoteList[indexPath.row].des.utf8)
            if let attributedString = try? NSAttributedString(data: attributeData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                cell.desLabel.text = attributedString.string
            }
            
        } else {
            cell.titleLabel.text = filteredNoteList[indexPath.row].title
            cell.desLabel.text = "locked"
        }
        return cell
    }
    
    
    //  MARK: - SEARCH FEATURE
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            filteredNoteList = allNoteList
            noteTableView.reloadData()
        } else {
            let searchBar = searchController.searchBar
            let selectedScope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            applySearch(searchText: searchBar.text!,scope: selectedScope)
        }
    }
    
    func applySearch(searchText: String, scope: String = "All") {
        if searchController.searchBar.text! == "" {
            switch scope {
            case "All":
                filteredNoteList = allNoteList
            case "Lock":
                filteredNoteList = allNoteList.filter { note in
                    let lockedNote = note.isLocked == true
                    return lockedNote
                }
            case "Unlock":
                filteredNoteList = allNoteList.filter { note in
                    let unlockNote = note.isLocked == false
                    return unlockNote
                }
            default:
                filteredNoteList = allNoteList
                print("default")
            }
            
            print(filteredNoteList)
        } else {
            // Filter the results based on the selected filer and search text
            filteredNoteList = allNoteList.filter { note in
                switch scope {
                case "All":
                    return (note.title.lowercased().contains(searchText.lowercased()) || note.des.lowercased().contains(searchText.lowercased()))
                case "Lock":
                    return note.isLocked == true && (note.title.lowercased().contains(searchText.lowercased()))
                case "Unlock":
                    return note.isLocked == false && (note.title.lowercased().contains(searchText.lowercased()) || note.des.lowercased().contains(searchText.lowercased()))
                default:
                    print("default")
                    return (note.title.lowercased().contains(searchText.lowercased()) || note.des.lowercased().contains(searchText.lowercased()))
                    
                }
            }
        }
        self.noteTableView.reloadData()
    }
    
    //    SEARCH WITH VOICE
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        applySearch(searchText: searchController.searchBar.text!,scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        showAlertWithInputStringForSearch(title: "Search", searchController: searchController)
    }
    
    //    MARK: - SWIPE TO DELETE & SHARE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // DELETE ACTION
        let deleteAction =  UITableViewRowAction(style: .destructive, title: "Delete", handler: {(action, indexPath)  in
            
            // check lock status to delete, no lock => delete, locked => input pass to delete
            if (self.filteredNoteList[indexPath.row].isLocked == false) {
                //  delete on firebase
                NoteViewModel.shared.deleteNote(uniqueID: self.filteredNoteList[indexPath.row].id, completion: { message in
                    print(message)
                })
                // delete note name in shared note list of some user that have access to this note
                SharedNoteViewModel.shared.deleteNoteInSharedUsers(uniqueID: self.filteredNoteList[indexPath.row].id)
                
                // delete noteList UI
                for note in self.allNoteList {
                    if note.id == self.filteredNoteList[indexPath.row].id {
                        self.allNoteList.removeAll{$0.id == note.id}
                    }
                }
                // delete filter UI
                self.filteredNoteList.remove(at: indexPath.row)
                self.noteTableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                // note locked => enter passcode to delete
                SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
                    self.enterPasscodeToDelete(passcode: passcode, indexPath: indexPath) // func enter passcode to delete
                })
            }
            self.noteTableView.reloadData()
        })
        
//        var swipeActions = [deleteAction]
//        if !filteredNoteList[indexPath.row].isLocked {
//            // SHARE ACTION
//            let shareAction = UITableViewRowAction(style: .normal, title: "Share", handler: { (action, indexPath) in
//                NoteViewModel.shared.getNoteList(completion: { notes in
//                    self.filteredNoteList = notes
//                    DispatchQueue.main.async {
//                        self.noteTableView.reloadData()
//                    }
//                    
//                    // note shared to specific users
//                    let sharedUsersStr = self.filteredNoteList[indexPath.row].sharedUsers.joined(separator: ", ")
//                    self.showShareAlert(title: "Share Note", message: "Share to: \(sharedUsersStr)",  noteToShare: self.filteredNoteList[indexPath.row].id, completion: { message in
//                        self.showResultShareAlert(title: "Shared Note", message: message)
//                        
//                    })
//                })
//            })
//            
//            shareAction.backgroundColor = UIColor.blue
//            swipeActions.append(shareAction)
//        }
        
        return [deleteAction]
        
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // DELETE ACTION
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {(contextualAction, view, boolValue) in
            
            // check lock status to delete, no lock => delete, locked => input pass to delete
            if (self.filteredNoteList[indexPath.row].isLocked == false) {
                //  delete on firebase
                NoteViewModel.shared.deleteNote(uniqueID: self.filteredNoteList[indexPath.row].id, completion: { message in
                    print(message)
                })
                // delete note name in shared note list of some user that have access to this note
                SharedNoteViewModel.shared.deleteNoteInSharedUsers(uniqueID: self.filteredNoteList[indexPath.row].id)
                
                // delete noteList UI
                for note in self.allNoteList {
                    if note.id == self.filteredNoteList[indexPath.row].id {
                        self.allNoteList.removeAll{$0.id == note.id}
                    }
                }
                // delete filter UI
                self.filteredNoteList.remove(at: indexPath.row)
                self.noteTableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                // note locked => enter passcode to delete
                SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
                    self.enterPasscodeToDelete(passcode: passcode, indexPath: indexPath) // func enter passcode to delete
                })
            }
            self.noteTableView.reloadData()
        })
        
        var swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        if !filteredNoteList[indexPath.row].isLocked {
            // SHARE ACTION
            let shareAction = UIContextualAction(style: .normal, title: "Share", handler: {(contextualAction, view, boolValue) in
                NoteViewModel.shared.getNoteList(completion: { notes in
                    self.filteredNoteList = notes
                    DispatchQueue.main.async {
                        self.noteTableView.reloadData()
                    }
                    
                    // note shared to specific users
                    let sharedUsersStr = self.filteredNoteList[indexPath.row].sharedUsers.joined(separator: ", ")
                    self.showShareAlert(title: "Share Note", message: "Share to: \(sharedUsersStr)",  noteToShare: self.filteredNoteList[indexPath.row].id, completion: { message in
                        self.showResultShareAlert(title: "Shared Note", message: message)
                        
                    })
                })
            })
            shareAction.backgroundColor = UIColor.blue
            swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        }
        return swipeActions
    }
    
    // enter passcode to delete
    func enterPasscodeToDelete(passcode: String, indexPath: IndexPath) {
        alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            PasscodeViewModel.shared.isHidden = false
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            textField.isSecureTextEntry = true
            
            self.setPasscodeIcon(name: "eye", textField: textField)
            PasscodeViewModel.shared.hiddenPwdIcon.addTarget(self, action: #selector(self.showAndHidePasscodeAction), for: .touchUpInside)
            textField.rightView = PasscodeViewModel.shared.hiddenPwdIcon
            textField.rightViewMode = .always
            
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = self.alert.textFields?.first?.text {
                print("Your password: \(password)")
                if password == passcode {
                    NoteViewModel.shared.deleteNote(uniqueID: self.filteredNoteList[indexPath.row].id, completion: { message in
                        print(message)
                    })
                    for note in self.allNoteList {
                        if note.id == self.filteredNoteList[indexPath.row].id {
                            self.allNoteList.removeAll{$0.id == note.id}
                        }
                    }
                    self.filteredNoteList.remove(at: indexPath.row)
                    self.noteTableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    print("incorrect passcode")
                    self.showAlert(title: .passcodeValidation, message: .wrong)
                }
                PasscodeViewModel.shared.isHidden = false
            }})
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //    MARK: - SHOW OR HIDE PASSCODE
    //toggle the eye icon to show or hide the passcode
    @objc func showAndHidePasscodeAction(_ sender: Any) {
//        PasscodeViewModel.shared.displayPasscode(textField: (alert.textFields?.first)!)
    }
    
    func setPasscodeIcon(name: String, textField: UITextField) {
//       PasscodeViewModel.shared.setPasscodeIcon(name: name, textField: textField)
    }
    
    
    //    MARK: - PERFORM SEGUES
    @objc func addNote() {
        self.performSegue(withIdentifier: "AddNewNote", sender: self)
    }
    
    @objc func exit() {
        let alert = UIAlertController(title: "Exit" , message: "Do you want to log out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            NoteViewModel.shared.logOutUser()
            self.performSegue(withIdentifier: "ShowLoginViewFromYourNote", sender: self)
        }))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditNote", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewNote" {
            let destinationVC  = segue.destination as! CreateNoteViewController
            destinationVC.uniqueID = NoteViewModel.shared.createNewUniqueNoteID(noteList: allNoteList)
        }

        if segue.identifier == "EditNote" {
            let destinationVC  = segue.destination as! NoteDetailViewController
            selectedRow = noteTableView.indexPathForSelectedRow!.row
            let uniqueID = filteredNoteList[selectedRow].id
            destinationVC.uniqueID = uniqueID
            let lockStatus = filteredNoteList[selectedRow].isLocked
            destinationVC.lockStatus = lockStatus
        }

        if segue.identifier == "ShowLoginViewFromYourNote" {
            _ = segue.destination as! LoginViewController
        }
    }
    
    
    //    MARK: - SET UP UI NAV & SEARCH CONTROLLER
    func setupNavUI() {
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        self.navigationItem.rightBarButtonItem = addBtn
        
        let exitBtn = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(exit))
        self.navigationItem.leftBarButtonItem = exitBtn
    }
    
    func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        noteTableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.scopeButtonTitles = ["All", "Lock", "Unlock"]
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Enter Keywords to search"
        
        searchController.searchBar.showsBookmarkButton = true
        if #available(iOS 13.0, *) {
            searchController.searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        } else {
            searchController.searchBar.setImage(UIImage(named: "searchVoice"), for: .bookmark, state: .normal)
            
        }
        // to hide it when the view is first presented.
        //        noteTableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
    }
}
