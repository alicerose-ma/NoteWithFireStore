//
//  ViewModeShareViewController.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 4/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class ViewModeShareViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var voiceBtn = UIBarButtonItem()
    var isRecord: Bool = false
    
    var mode: String = ""
    var titleStr: String = ""
    var desStr: String = ""
    var email: String = ""
    var id: Int = -1
    var sharedUsers: [String] = []
    var imageIDMax = -1
    var imagePosition: [Int]  = []
    var imageURL: [String] = []
    
    var timer = Timer()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        VoiceViewModel.shared.voiceSetup()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
        registerForKeyboardNotifications()
        scheduleEditPermission()
    }
    
    func scheduleEditPermission() {
        if mode == "view" {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(_scheduleEditPermission), userInfo: nil, repeats: true)
    }
    
    @objc func _scheduleEditPermission() {
        let documentId = email + "note" + String(id)
        let now = Int64(NSDate().timeIntervalSince1970)
        print("_scheduleEditPermission: email: \(email), time: \(now)")
        FireBaseProxy.shared.updateNoteEditing(documentId: documentId, timeStamp: now, user: NoteViewModel.shared.username!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBarUI()
        setupTextViewWithDoneBtn()
        self.title = "\(mode)".capitalizingFirstLetter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadNoteByID()
    }
    
    func loadNoteByID() {
        SharedNoteViewModel.shared.getNoteByIDForShare(email: email, id: id, completion: { notes in
            self.titleTextField.text = notes[0].title
            self.desTextView.text = notes[0].des
        })
        
        if mode == "view" {
            titleTextField.isEnabled = false
            desTextView.isSelectable = false
        } else {
            titleTextField.isEnabled = true
            desTextView.isSelectable = true
            setupTextViewWithDoneBtn()
            let documentID =  email + "note" + String(id)
            let now = Int64(NSDate().timeIntervalSince1970)
            FireBaseProxy.shared.updateNoteEditing(documentId: documentID, timeStamp: now, user: NoteViewModel.shared.username!)
//            FireBaseProxy.shared.updateIsEditing(documentID: documentID, isEditing: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
        saveNote()
    }
    
    func saveNote(){
        VoiceViewModel.shared.stopRecording()
        deregisterFromKeyboardNotifications()
        if mode == "edit" {
            let title = titleTextField.text!
            var description = desTextView.text!
            description  = description.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
            let lastTime = Int64(NSDate().timeIntervalSince1970 - 5000)
            
            var note = NoteData(id: id, email: email, title: title, des: description, isLocked: false, isEditing: false, imageIDMax: imageIDMax, sharedUsers: sharedUsers ,imagePosition: imagePosition, imageURL: imageURL, lastUpdateTime: lastTime, lastUpdateUser: NoteViewModel.shared.username!) //create a new note model with lock
            
            if !title.isEmpty && !desTextView.attributedText.string.isEmpty  {
                SharedNoteViewModel.shared.editSharedNote(email: email, id: id, newNote: note)
            } else if title.isEmpty && !desTextView.attributedText.string.isEmpty {
                note.title = "Undefined title"
                SharedNoteViewModel.shared.editSharedNote(email: email, id: id, newNote: note)
            } else if !title.isEmpty && desTextView.attributedText.string.isEmpty {
                note.des = "No description"
                SharedNoteViewModel.shared.editSharedNote(email: email, id: id, newNote: note)
            } else {
                note.title = "Undefined title"
                note.des = "No description"
                SharedNoteViewModel.shared.editSharedNote(email: email, id: id, newNote: note)
            }
            
            SharedNoteViewModel.shared.sharedUsers = []
        }
         self.tabBarController?.tabBar.isHidden = false
    }
    
    //  MARK: -  TEXT DESCRIBED FROM VOICE
    @objc func voice(){
        VoiceViewModel.shared.clickRecordBtn(titleTextField: titleTextField, desTextView: desTextView, viewController: self)
        if isRecord {
            changeNavButtonItemForIOS12AndIOS13(name: "mic")
        } else {
            if #available(iOS 13.0, *) {
                voiceBtn.image = UIImage(systemName: "mic.slash")
            } else {
                voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "micSlash", action:  #selector(self.voice)))
            }
            navigationItem.rightBarButtonItems = [voiceBtn]
        }
        isRecord = !isRecord
    }
    
    
    //    MARK: - IMAGE
    @objc func addImage(){
        print("click add image")
    }
    
}


extension ViewModeShareViewController{
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //    MARK: SWITCH BETWEEN TEXTFIELD & TEXTVIEW
    //    switch between textfield and textview => stop record
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switchBetweenTextFieldAndTextView()
    }
    
    //     image only add in textview
    func textViewDidBeginEditing(_ textView: UITextView) {
        switchBetweenTextFieldAndTextView()
    }
    
    func switchBetweenTextFieldAndTextView() {
        VoiceViewModel.shared.stopRecording()
        isRecord = false
        changeNavButtonItemForIOS12AndIOS13(name: "mic")
    }
    
    func changeNavButtonItemForIOS12AndIOS13(name: String){
        if #available(iOS 13.0, *) {
            voiceBtn.image = UIImage(systemName: name)
        } else {
            voiceBtn = UIBarButtonItem(customView: UIImageIO12And13Helper.shared.createBarButtonItem(name: name, action:  #selector(self.voice)))
        }
        navigationItem.rightBarButtonItems = [voiceBtn]
    }
    
    //    MARK: - SETUP UI
    func setupDelegate(){
        titleTextField.delegate = self
        desTextView.delegate = self
    }
    
    func setUpNavBarItem() {
        if #available(iOS 13.0, *) {
            voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
        } else {
            voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "mic", action:  #selector(self.voice)))
        }
    }
    
    func setupNavBarUI() {
        setUpNavBarItem()
        if mode == "edit" {
            navigationItem.rightBarButtonItems = [voiceBtn]
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - AUTO KEYBOARD FOR TEXTVIEW
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name:  UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name:  UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 20, right: 0.0)
        
        desTextView.scrollIndicatorInsets = contentInsets
        desTextView.contentInset = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        desTextView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        desTextView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.view.endEditing(true)
    }
    
    //      set up textview with done button to dimiss the keyboard
    func setupTextViewWithDoneBtn() {
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.size.width, height: 30)))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnAction))
        barButton.tintColor = .blue
        toolBar.setItems([flexible, barButton], animated: false)
        desTextView.inputAccessoryView = toolBar
        
    }
    
    @objc func doneBtnAction() {
        self.view.endEditing(true)
    }
}
