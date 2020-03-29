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
    let searchController = UISearchController(searchResultsController: nil)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavUI()
        setupSearchController()
        VoiceViewModel.shared.voiceSetup()
    }
    
    
    // MARK: - CHECK USER LOGIN BEFORE
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didLogin()
        searchController.searchBar.text = nil
    }
    
    //    check if user login before
    func didLogin() {
        let didLogin = NoteViewModel.shared.didLogin()
        if didLogin {
            loadNoteList()
        } else {
            UIView.setAnimationsEnabled(false)
            self.performSegue(withIdentifier: "ShowLoginViewFromYourNote", sender: self)
        }
    }
    
    //    load note list of user
    func loadNoteList() {
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
        
        if !filteredNoteList[indexPath.row].isLocked {
            cell.titleLabel.text = filteredNoteList[indexPath.row].title
            cell.desLabel.text = filteredNoteList[indexPath.row].des
        } else {
            cell.titleLabel.text = filteredNoteList[indexPath.row].title
            cell.desLabel.text = "locked"
        }
        return cell
    }
    
    
    //  MARK: - SEARCH FEATURE
    //   called when search bar is reponsder or user makes change inside search bar
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
        } else {
            // Filter the results based on the selected filer and search text
            filteredNoteList = allNoteList.filter { note in
                switch scope {
                case "All":
                    return (note.isLocked == true && note.title.lowercased().contains(searchText.lowercased())) ||
                        (note.isLocked == false && (note.title.lowercased().contains(searchText.lowercased()) || note.des.lowercased().contains(searchText.lowercased())))
                case "Lock":
                    return note.isLocked == true && (note.title.lowercased().contains(searchText.lowercased()))
                case "Unlock":
                    return note.isLocked == false && (note.title.lowercased().contains(searchText.lowercased()) || note.des.lowercased().contains(searchText.lowercased()))
                default:
                    return (note.isLocked == true && note.title.lowercased().contains(searchText.lowercased())) ||
                        (note.isLocked == false && (note.title.lowercased().contains(searchText.lowercased()) || note.des.lowercased().contains(searchText.lowercased())))
                }
            }
        }
        self.noteTableView.reloadData()
    }
    
    //    change scope recognition
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        applySearch(searchText: searchController.searchBar.text!,scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    
    //    Search with voice
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        showAlertWithInputStringForSearch(title: "Search", searchController: searchController)
    }
    
    
    //    MARK: - SWIPE TO DELETE FOR IOS 10 and IOS 13
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // DELETE ACTION
        let deleteAction =  UITableViewRowAction(style: .destructive, title: "Delete", handler: {(action, indexPath)  in
            self.deleteAction(indexPath: indexPath)
        })
        return [deleteAction]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // DELETE ACTION
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {(contextualAction, view, boolValue) in
            self.deleteAction(indexPath: indexPath)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //    delete action for swipe left
    func deleteAction(indexPath: IndexPath){
        // check lock status to delete, no lock => delete, locked => input pass to delete
        if !self.filteredNoteList[indexPath.row].isLocked {
            executeDeleteNote(indexPath: indexPath) //execute delete
        } else {
            // note locked => enter passcode to delete
            SetPasscodeViewModel.shared.getUserPasscode(completion: { passcode in
                self.enterPasscodeToDelete(passcode: passcode, indexPath: indexPath)
            })
        }
        self.noteTableView.reloadData()
    }
    
    // alert shows for user to enter passcode to delete
    func enterPasscodeToDelete(passcode: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            textField.isSecureTextEntry = true
            PasscodeViewModel.shared.textField = textField
            PasscodeViewModel.shared.setupPasswordIcon(color: .black)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
                print("Your password: \(password)")
                if password == passcode {
                    self.executeDeleteNote(indexPath: indexPath) //execute delete
                } else {
                    self.showWrongPasscodeAlert(title: .passcodeValidation, message: .wrong)
                }
            }})
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    //  actual processes to delete note
    func executeDeleteNote(indexPath: IndexPath){
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
        
        // delete filtered list UI
        self.filteredNoteList.remove(at: indexPath.row)
        self.noteTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    
    //    MARK: - PERFORM SEGUES
    @objc func addNote() {
        self.performSegue(withIdentifier: "AddNewNote", sender: self)
    }
    
    @objc func exit() {
        exitAlert(identifier: "ShowLoginViewFromYourNote")
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
        self.title = "Notes"
        noteTableView.dataSource = self
        noteTableView.delegate = self
        
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
        searchController.hidesNavigationBarDuringPresentation = false
        
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

