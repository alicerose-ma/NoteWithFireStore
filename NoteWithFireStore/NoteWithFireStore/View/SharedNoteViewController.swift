//
//  SharedNoteViewController.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/25/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class SharedNoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var allSharedNoteList = [NoteData]()
    @IBOutlet weak var sharedTableView: UITableView!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sharedTableView.delegate = self
        sharedTableView.dataSource = self
        self.title = "Notes"
        setupNavUI()

        print(SharedNoteViewModel.shared.sharedNotes)
    }

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           loadNoteList()
    }

//           check if user login before
       func didLogin() {
        let didLogin = NoteViewModel.shared.didLogin()
           if didLogin {
               loadNoteList()
           } else {
               self.performSegue(withIdentifier: "ShowLoginViewFromSharedNote", sender: self)
           }
       }

       //    load note list of user
       func loadNoteList() {

        SharedNoteViewModel.shared.getSharedNote(username: SharedNoteViewModel.shared.username!, completion: { notes in
            print(notes)
            self.allSharedNoteList = notes
            DispatchQueue.main.async {
                self.sharedTableView.reloadData()
            }
        })
       }


//    MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 100
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSharedNoteList.count
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell =  sharedTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
                  if (allSharedNoteList[indexPath.row].isLocked == false) {
                      cell.titleLabel.text = allSharedNoteList[indexPath.row].title

                      let attributeData = Data(allSharedNoteList[indexPath.row].des.utf8)
                      if let attributedString = try? NSAttributedString(data: attributeData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                          cell.desLabel.text = attributedString.string
                      }

                  } else {
                      cell.titleLabel.text = allSharedNoteList[indexPath.row].title
                      cell.desLabel.text = "locked"
                  }
                  return cell
      }


//    set up UI
    func setupNavUI() {
        let exitBtn = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(exit))
        self.navigationItem.leftBarButtonItem = exitBtn
    }

    @objc func exit() {
        let alert = UIAlertController(title: "Exit" , message: "Do you want to log out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            NoteViewModel.shared.logOutUser()
            self.performSegue(withIdentifier: "ShowLoginViewFromSharedNote", sender: self)
        }))
        self.present(alert, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLoginViewFromSharedNote" {
                   _ = segue.destination as! LoginViewController
        }
    }

}
