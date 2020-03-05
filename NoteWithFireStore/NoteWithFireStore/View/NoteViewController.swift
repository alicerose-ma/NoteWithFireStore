//
//  NoteViewController.swift
//  note
//
//  Created by Ma Alice on 1/20/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit


class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Alertable, UISearchResultsUpdating, UISearchBarDelegate {
    
    var filteredCandies: [NoteData] = []
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }


    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)

    }
    
    func filterContentForSearchText(_ searchText: String) {
//      filteredCandies = allNoteList.filter { (note: NoteData) -> Bool in
//        return note.title.lowercased().contains(searchText.lowercased())
//      }
        
        if isFiltering {
            let filterdata = allNoteList.filter { ($0.title.range(of: searchText, options: .caseInsensitive) != nil) || ($0.des.range(of: searchText, options: .caseInsensitive) != nil) }
             filterNoteList = filterdata
        } else {
            filterNoteList = allNoteList
        }
             
      
      noteTableView.reloadData()
    }
    
    
    
    @IBOutlet weak var noteTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let searchController = UISearchController(searchResultsController: nil)

    
    var noteViewModel =  NoteViewModel()
    var setPasscodeViewModel = SetPasscodeViewModel()
    var selectedRow: Int = -1
    
    var filterNoteList = [NoteData]()
    var allNoteList = [NoteData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTableView.dataSource = self
        noteTableView.delegate = self
        searchBar.delegate = self
        searchController.searchBar.delegate = self
        self.title = "Notes"
        setupNavUI()
        alterLayout()
    }
    
    func alterLayout(){
        // 1
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Candies"
        searchController.searchBar.scopeButtonTitles = ["All","Unlock","Lock"]
        searchController.searchBar.showsScopeBar = true
        // 4
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
    }
 
//    search bar for filter notes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filterdata = searchText.isEmpty ? allNoteList : allNoteList.filter { ($0.title.range(of: searchText, options: .caseInsensitive) != nil) || ($0.des.range(of: searchText, options: .caseInsensitive) != nil) }

        if !searchText.isEmpty {
            filterNoteList = filterdata
        } else {
            filterNoteList = allNoteList
        }
        noteTableView.reloadData()
    }
//
//
//        filterNoteList = allNoteList.filter({ note -> Bool in
//            switch searchBar.selectedScopeButtonIndex {
//            case 0:
//                if searchText.isEmpty { return true }
//                return (note.title.range(of: searchText, options: .caseInsensitive) != nil) || (note.des.range(of: searchText, options: .caseInsensitive) != nil)
//            case 1:
//                if searchText.isEmpty { return note.isLocked == true }
//                return (note.title.range(of: searchText, options: .caseInsensitive) != nil) || (note.des.range(of: searchText, options: .caseInsensitive) != nil) && note.isLocked == true
//            case 2:
//                if searchText.isEmpty { return note.isLocked == false }
//                return (note.title.range(of: searchText, options: .caseInsensitive) != nil) || (note.des.range(of: searchText, options: .caseInsensitive) != nil) && note.isLocked == false
//            default:
//                return false
//            }
//        })
//        noteTableView.reloadData()
//    }
//
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
      switch selectedScope {
      case 0:
          filterNoteList = allNoteList
      case 1:
          filterNoteList = allNoteList.filter({ note -> Bool in
            note.isLocked == true
          })
      case 2:
          filterNoteList = allNoteList.filter({ note -> Bool in
            note.isLocked == false
          })
      default:
          break
      }
        print(filterNoteList)
      noteTableView.reloadData()

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
        searchController.searchBar.text = ""
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
            self.filterNoteList = notes
            self.allNoteList = notes
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
            return filterNoteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  noteTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
            if (filterNoteList[indexPath.row].isLocked == false) {
                cell.titleLabel.text = filterNoteList[indexPath.row].title
                cell.desLabel.text = filterNoteList[indexPath.row].des
            } else {
                cell.titleLabel.text = filterNoteList[indexPath.row].title
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
                if (self.filterNoteList[indexPath.row].isLocked == false) {
//                    delete on firebase
                    self.noteViewModel.deleteNote(uniqueID: self.filterNoteList[indexPath.row].id, completion: { message in
                        print(message)
                    })

//                    delete noteList UI
                    for note in self.allNoteList {
                        if note.id == self.filterNoteList[indexPath.row].id {
                            self.allNoteList.removeAll{$0.id == note.id}
                        }
                    }
//                    delete filter UI
                    self.filterNoteList.remove(at: indexPath.row)
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
                    self.noteViewModel.deleteNote(uniqueID: self.filterNoteList[indexPath.row].id, completion: { message in
                        print(message)
                    })
                    for note in self.allNoteList {
                        if note.id == self.filterNoteList[indexPath.row].id {
                            self.allNoteList.removeAll{$0.id == note.id}
                        }
                    }
                    self.filterNoteList.remove(at: indexPath.row)
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
            destinationVC.uniqueID = noteViewModel.createNewUniqueNoteID(noteList: filterNoteList)
        }
        
        if segue.identifier == "EditNote" {
                let destinationVC  = segue.destination as! NoteDetailViewController
                selectedRow = noteTableView.indexPathForSelectedRow!.row
                let uniqueID = filterNoteList[selectedRow].id
                destinationVC.uniqueID = uniqueID
                let lockStatus = filterNoteList[selectedRow].isLocked
                destinationVC.lockStatus = lockStatus
//            }
        }
        
        if segue.identifier == "ShowLoginView" {
            _ = segue.destination as! LoginViewController
        }
    }
    
}
