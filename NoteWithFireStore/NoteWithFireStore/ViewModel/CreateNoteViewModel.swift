//
//  CreateNoteVIewModel.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit

class CreateNoteViewModel {
    let username = UserDefaults.standard.string(forKey: "username")
    
    public func addNewNote(documentID: String, newNote: NoteData) {
        FireBaseProxy.shared.addNewNote(documentID: documentID, newNote: newNote)
    }
    
    public func createUniqueNoteDocID(username: String, uniqueID: Int) -> String {
        return username + "note" + String(uniqueID)
    }
    
    public func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
       
        if let topVC = UIApplication.getTopViewController() {
           topVC.present(alert, animated: true)
        }
    }
    
}

extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

