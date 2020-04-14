//
//  SharedNoteViewController.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/25/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class SharedNoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Alertable, UISearchResultsUpdating, UISearchControllerDelegate ,UISearchBarDelegate {

    var allSharedNoteList = [(NoteData,String)]()
    var filteredSharedList = [(NoteData,String)]()
    var modeArr = [String]()
    var selectedRow: Int =  -1
    
    @IBOutlet weak var emptyNoteView: UIView!
    @IBOutlet weak var sharedTableView: UITableView!
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavUI()
        setupSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.text = nil
        searchController.searchBar.selectedScopeButtonIndex = 0
    }

    
    override func viewDidAppear(_ animated: Bool) {
        loadNoteList()
    }
    
    func loadNoteList() {
        let alert = UIAlertController(title: "Loading" , message: nil, preferredStyle: .alert)
        waitAlert(alert: alert)
        SharedNoteViewModel.shared.getSharedNotes(completion: { noteArr in
            print("arr = \(noteArr)")
            if noteArr.count == 0 {
                DispatchQueue.main.async {
                    alert.dismiss(animated: false, completion: {
                        self.emptyNoteView.isHidden = false
                    })
                }
            } else {
                SharedNoteViewModel.shared.sharedNotes = noteArr
                self.allSharedNoteList = noteArr
                self.filteredSharedList = noteArr
                self.allSharedNoteList = self.allSharedNoteList.sorted(by: {$0.0.title.lowercased() < $1.0.title.lowercased()})
                self.filteredSharedList = self.filteredSharedList.sorted(by: {$0.0.title.lowercased() < $1.0.title.lowercased()})
                
                DispatchQueue.main.async {
                    alert.dismiss(animated: false, completion: {
                        self.emptyNoteView.isHidden = true
                        self.sharedTableView.reloadData()
                    })
                }
            }
        })
    }
    
    //  MARK: - SEARCH FEATURE
     //   called when search bar is reponsder or user makes change inside search bar
     func updateSearchResults(for searchController: UISearchController) {
         if !searchController.isActive {
             filteredSharedList = allSharedNoteList
             sharedTableView.reloadData()
         } else {
             let searchBar = searchController.searchBar
             let selectedScope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
             applySearch(searchText: searchBar.text!,scope: selectedScope)
         }
     }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.isActive = true
        return true
    }

     func applySearch(searchText: String, scope: String = "All") {
         if searchController.searchBar.text! == "" {
             switch scope {
             case "All":
                 filteredSharedList = allSharedNoteList
             case "View":
                 filteredSharedList = allSharedNoteList.filter { tupleNote in
                    let viewNote = tupleNote.1 == "view"
                     return viewNote
                 }
             case "Edit":
                 filteredSharedList = allSharedNoteList.filter { tupleNote in
                    let viewNote = tupleNote.1 == "edit"
                     return viewNote
                 }
             default:
                 filteredSharedList = allSharedNoteList
                 print("default")
             }
         } else {
//              Filter the results based on the selected filer and search text
            filteredSharedList = allSharedNoteList.filter { tupleNote in
                switch scope {
                case "All":
                    return (tupleNote.1 == "view" && tupleNote.0.title.lowercased().contains(searchText.lowercased())) ||
                        (tupleNote.1 == "edit" && (tupleNote.0.title.lowercased().contains(searchText.lowercased()) || tupleNote.0.des.lowercased().contains(searchText.lowercased())))
                case "View":
                    return tupleNote.1 == "view" && (tupleNote.0.title.lowercased().contains(searchText.lowercased()) || tupleNote.0.des.lowercased().contains(searchText.lowercased()))
                case "Edit":
                    return tupleNote.1 == "edit" && (tupleNote.0.title.lowercased().contains(searchText.lowercased()) || tupleNote.0.des.lowercased().contains(searchText.lowercased()))
                default:
                    return (tupleNote.1 == "view" && tupleNote.0.title.lowercased().contains(searchText.lowercased())) ||
                        (tupleNote.1 == "edit" && (tupleNote.0.title.lowercased().contains(searchText.lowercased()) || tupleNote.0.des.lowercased().contains(searchText.lowercased())))
                 }
             }
         }
         self.sharedTableView.reloadData()
     }
     
     //    change scope recognition
     func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
         applySearch(searchText: searchController.searchBar.text!,scope: searchBar.scopeButtonTitles![selectedScope])
     }
     
     //    Search with voice
     func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
         showAlertWithInputStringForSearch(title: "Search", searchController: searchController)
     }
    
    
    //    MARK: DELETE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // DELETE ACTION
        let deleteAction =  UITableViewRowAction(style: .destructive, title: "Delete", handler: {(action, indexPath)  in
            let email = self.filteredSharedList[indexPath.row].0.email
            let id = self.filteredSharedList[indexPath.row].0.id
            let mode = self.filteredSharedList[indexPath.row].1
            SharedNoteViewModel.shared.deleteOneNoteForOneUserFromShareView(userToShare: email, uniqueID: id, mode: mode, completion: { deleted in
                if deleted {
                    self.loadNoteList()
                }
            })
        })
        return [deleteAction]
    }


    // MARK: - SEGUE
    @objc func exit() {
        exitAlert(identifier: "ShowLoginViewFromSharedNote")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowViewMode", sender: self)
    }
    
    @objc func refreshTableView(_ sender: Any) {
        loadNoteList()
        self.refreshControl.endRefreshing()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLoginViewFromSharedNote" {
            let nav = segue.destination as! UINavigationController
            nav.modalPresentationStyle = .fullScreen
        }
        
        if segue.identifier == "ShowViewMode" {
            let destinationVC  = segue.destination as! ViewModeShareViewController
            selectedRow = sharedTableView.indexPathForSelectedRow!.row
            let mode = filteredSharedList[selectedRow].1
            destinationVC.mode = mode
            destinationVC.titleStr = filteredSharedList[selectedRow].0.title
            destinationVC.desStr = filteredSharedList[selectedRow].0.des
            destinationVC.email = filteredSharedList[selectedRow].0.email
            destinationVC.id = filteredSharedList[selectedRow].0.id
            destinationVC.sharedUsers = filteredSharedList[selectedRow].0.sharedUsers
            destinationVC.imageIDMax = filteredSharedList[selectedRow].0.imageIDMax
            destinationVC.imagePosition = filteredSharedList[selectedRow].0.imagePosition
            destinationVC.imageURL = filteredSharedList[selectedRow].0.imageURL
        }
    }

}


extension SharedNoteViewController{
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //    MARK: - TABLEVIEW DISPLAY NOTE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSharedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  sharedTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        cell.titleLabel.text = filteredSharedList[indexPath.row].0.title
        cell.desLabel.text = filteredSharedList[indexPath.row].0.des
        cell.modeLabel.text = "Mode: \(filteredSharedList[indexPath.row].1)"
        return cell
    }
    
    //    MARK: SET UP UI & SEARCH CONTROLLER
    func setupNavUI() {
        sharedTableView.delegate = self
        sharedTableView.dataSource = self
        self.title = "Shared Notes"
        
        let exitBtn = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(exit))
        self.navigationItem.leftBarButtonItem = exitBtn
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        
        if #available(iOS 10.0, *) {
            sharedTableView.refreshControl = refreshControl
        } else {
            sharedTableView.addSubview(refreshControl)
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
    }
    
    
    func setupSearchController(){
            self.navigationController!.navigationBar.barTintColor = .blue
            searchController.delegate = self
            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self
            
            searchController.obscuresBackgroundDuringPresentation = false
            definesPresentationContext = true

            searchController.searchBar.scopeButtonTitles = ["All", "View", "Edit"]
    //        change color of scope bar
            searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
            searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)

            searchController.searchBar.placeholder = "Enter Keywords to search"
            searchController.hidesNavigationBarDuringPresentation = true
            searchController.searchBar.showsBookmarkButton = true
            searchController.searchBar.sizeToFit()
            
            
            if #available(iOS 13.0, *) {
                self.navigationItem.searchController = searchController
                self.navigationItem.hidesSearchBarWhenScrolling = false
                searchController.searchBar.searchTextField.textColor = .white
                searchController.searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
            } else {
                sharedTableView.tableHeaderView = searchController.searchBar
                let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
                textFieldInsideSearchBar?.textColor = .white
                searchController.searchBar.setImage(UIImage(named: "searchVoice"), for: .bookmark, state: .normal)
                
            }
        }
        
    
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
