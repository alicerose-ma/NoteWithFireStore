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
    
    var alert = UIAlertController()
    var isPasscodeRecord  = false
    
    let voiceViewModel = VoiceViewModel()
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var noteTableView: UITableView!
    
    var noteViewModel =  NoteViewModel()
    var setPasscodeViewModel = SetPasscodeViewModel()
    var selectedRow: Int = -1
    
    var allNoteList = [NoteData]()
    var filteredNoteList = [NoteData]()
    
    
    var pinList = [NoteData]()
    var data = [[NoteData]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        pinList.append(NoteData(username: "AA", id: 777, title: "AAA", des: "AAA", isLocked: false))
        noteTableView.dataSource = self
        noteTableView.delegate = self
        self.title = "Notes"
        setupNavUI()
        setupSearchController()
        voiceViewModel.voiceSetupWithoutRecordBtn()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (pinList.count == 0) {
            data = [filteredNoteList]
        } else {
            data = [pinList,filteredNoteList]
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (pinList.count == 0) {
            data = [filteredNoteList]
        } else {
            data = [pinList,filteredNoteList]
        }
        return data[section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerTitles = ["Notes"]
        if section < headerTitles.count {
            return headerTitles[section]
        }
        
        return nil
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  noteTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        //        if (filteredNoteList[indexPath.row].isLocked == false) {
        //            cell.titleLabel.text = filteredNoteList[indexPath.row].title
        //            cell.desLabel.text = filteredNoteList[indexPath.row].des
        //        } else {
        //            cell.titleLabel.text = filteredNoteList[indexPath.row].title
        //            cell.desLabel.text = "locked"
        //        }
        //        return cell
        
        if (pinList.count == 0) {
            data = [filteredNoteList]
        } else {
            data = [pinList,filteredNoteList]
        }
        
        if (data[indexPath.section][indexPath.row].isLocked == false) {
            cell.titleLabel.text = data[indexPath.section][indexPath.row].title
            cell.desLabel.text = data[indexPath.section][indexPath.row].des
        } else {
            cell.titleLabel.text = data[indexPath.section][indexPath.row].title
            cell.desLabel.text = "locked"
        }
        return cell
        
        
        //        cell.titleLabel.text = data[indexPath.section][indexPath.row].title
        //        return cell
    }
    
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            filteredNoteList = allNoteList
            noteTableView.reloadData()
        } else {
            let searchBar = searchController.searchBar
            let selectedScope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            applySearch(searchText: searchController.searchBar.text!,scope: selectedScope)
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
                var newScope = ""
                if (note.isLocked == true) {
                    newScope = "Lock"
                } else {
                    newScope = "Unlock"
                }
                let lockList = (scope == "All") || (newScope == scope)
                return lockList && (note.title.lowercased().contains(searchText.lowercased()) || note.des.lowercased().contains(searchText.lowercased()))
            }
        }
        
        self.noteTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        applySearch(searchText: searchController.searchBar.text!,scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
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
        searchController.searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        // to hide it when the view is first presented.
        //        noteTableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didLogin()
        searchController.searchBar.text = nil
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
            self.allNoteList = notes
            self.filteredNoteList = notes
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
            if (self.filteredNoteList[indexPath.row].isLocked == false) {
                //                    delete on firebase
                self.noteViewModel.deleteNote(uniqueID: self.filteredNoteList[indexPath.row].id, completion: { message in
                    print(message)
                })
                
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
                self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
                    self.enterPasscodeToDelete(passcode: passcode, indexPath: indexPath)
                })
            }
            self.noteTableView.reloadData()
            
        })
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    @objc func recordPasscodeStart(_ sender: Any) {
        print("start passcode")
        
        alert.message = "Is Recording ..."
        voiceViewModel.startRecordingForPasscode(textField: (alert.textFields?.first)!)
        alert.textFields?.first?.rightView = nil
        isPasscodeRecord = false
        
        //        self.showAlertWithInputStringForPasscode(title: "Say passcode", tf: self.alert.textFields?.first)
    }
    
//    @objc func recordPasscodeStop(_ sender: Any) {
//        print("stop passcode ")
//        isPasscodeRecord = false
//        voiceViewModel.stopRecording()
//    }
    
    func enterPasscodeToDelete(passcode: String, indexPath: IndexPath) {
        alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.voiceViewModel.stopRecording()
        }))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
            
            let micStart = UIButton(type: .custom)
            micStart.setImage(UIImage(systemName: "mic"), for: .normal)
            micStart.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            micStart.frame = CGRect(x: CGFloat(textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
            micStart.addTarget(self, action: #selector(self.recordPasscodeStart), for: .touchUpInside)
            
//            let micStop = UIButton(type: .custom)
//            micStop.setImage(UIImage(systemName: "mic.circle"), for: .normal)
//            micStop.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
//            micStop.frame = CGRect(x: CGFloat(self.textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
//            micStop.addTarget(self, action: #selector(self.recordPasscodeStop), for: .touchUpInside)
//
//            passTextField = textField

//            if (!self.isPasscodeRecord) {
//                textField.rightView = micStart
//                print("start")
//
//            } else{
//                textField.rightView = micStop
//                print("stop")
//
//            }
            textField.rightView = micStart
            textField.rightViewMode = .unlessEditing
            
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.voiceViewModel.stopRecording()
            if let password = self.alert.textFields?.first?.text {
                print("Your password: \(password)")
                if password == passcode {
                    self.noteViewModel.deleteNote(uniqueID: self.filteredNoteList[indexPath.row].id, completion: { message in
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
            }})
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    //    transfer to other views by identifier
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewNote" {
            let destinationVC  = segue.destination as! CreateNoteViewController
            destinationVC.uniqueID = noteViewModel.createNewUniqueNoteID(noteList: allNoteList)
        }
        
        if segue.identifier == "EditNote" {
            let destinationVC  = segue.destination as! NoteDetailViewController
            selectedRow = noteTableView.indexPathForSelectedRow!.row
            let uniqueID = filteredNoteList[selectedRow].id
            destinationVC.uniqueID = uniqueID
            let lockStatus = filteredNoteList[selectedRow].isLocked
            destinationVC.lockStatus = lockStatus
            //            }
        }
        
        if segue.identifier == "ShowLoginView" {
            _ = segue.destination as! LoginViewController
        }
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        showAlertWithInputString(title: "Search", searchController: searchController)
    }
    
    
    
}
