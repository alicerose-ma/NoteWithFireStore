//
//  SharedNoteViewController.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/25/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class SharedNoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Alertable {

    var allSharedNoteList = [NoteData]()
    var modeArr = [String]()
    @IBOutlet weak var emptyNoteView: UIView!
    @IBOutlet weak var sharedNoteTableView: UITableView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sharedNoteTableView.delegate = self
        sharedNoteTableView.dataSource = self
        self.title = "Shared Notes"
        setupNavUI()
        loadNoteList()

        print(SharedNoteViewModel.shared.sharedNotes) 
    }

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        loadNoteList()
        allSharedNoteList = SharedNoteViewModel.shared.sharedNotes
        print(allSharedNoteList)
        
        if allSharedNoteList.count != 0 {
            emptyNoteView.isHidden = true
        } else {
            emptyNoteView.isHidden = false
        }
    }

    
    func loadNoteList() {
        SharedNoteViewModel.shared.getSharedNote(completion: { sharedNotesStr in
            var arr: [[String]] = []
            for noteStr in sharedNotesStr {
                let emailAndIDWithMode = noteStr.components(separatedBy: "note")
                let idAndMode = emailAndIDWithMode[1].components(separatedBy: "mode")
                
                let email = emailAndIDWithMode[0]
                let id = idAndMode[0]
                let mode = idAndMode[1]
                var str: [String] = []
                str.append(email)
                str.append(id)
                str.append(mode)
                
                arr.append(str)
            }
            print(arr)
            SharedNoteViewModel.shared.sharedNotes = []
            for str in arr {
                FireBaseProxy.shared.getNoteByID(email: str[0], id: Int(str[1])!, completion: { notes in
                    SharedNoteViewModel.shared.sharedNotes.append(contentsOf: notes)
//                    self.allSharedNoteList.append(contentsOf: notes)
                })
            }
        })
    }


//    MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 200
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSharedNoteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  sharedNoteTableView.dequeueReusableCell(withIdentifier: "share", for: indexPath)
        cell
        return cell
    }

//    set up UI
    func setupNavUI() {
        let exitBtn = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(exit))
        self.navigationItem.leftBarButtonItem = exitBtn
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
    }

    @objc func exit() {
        exitAlert(identifier: "ShowLoginViewFromSharedNote")
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLoginViewFromSharedNote" {
            let nav = segue.destination as! UINavigationController
            nav.modalPresentationStyle = .fullScreen
        }
    }

}
