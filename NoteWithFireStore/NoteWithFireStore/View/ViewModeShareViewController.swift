//
//  ViewModeShareViewController.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 4/11/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit

class ViewModeShareViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var voiceBtn = UIBarButtonItem()
    var imageBtn = UIBarButtonItem()
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
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        VoiceViewModel.shared.voiceSetup()
        KeyboardHelper.shared.dismissKeyboard(viewController: self)
        registerForKeyboardNotifications()
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
            FireBaseProxy.shared.updateIsEditing(documentID: documentID, isEditing: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveNote()
    }
    
    func saveNote(){
        VoiceViewModel.shared.stopRecording()
        deregisterFromKeyboardNotifications()
        if mode == "edit" {
            let title = titleTextField.text!
            var description = desTextView.text!
            description  = description.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
            
            var note = NoteData(id: id, email: email, title: title, des: description, isLocked: false, isEditing: false, imageIDMax: imageIDMax, sharedUsers: sharedUsers ,imagePosition: imagePosition, imageURL: imageURL ) //create a new note model with lock
            
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
    }
    
    //  MARK: -  TEXT DESCRIBED FROM VOICE
    @objc func voice(){
        VoiceViewModel.shared.clickRecordBtn(titleTextField: titleTextField, desTextView: desTextView, viewController: self)
        if isRecord {
            imageBtn.isEnabled = false
            changeNavButtonItemForIOS12AndIOS13(name: "mic")
        } else {
            imageBtn.isEnabled = false
            if #available(iOS 13.0, *) {
                voiceBtn.image = UIImage(systemName: "mic.slash")
            } else {
                voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "micSlash", action:  #selector(self.voice)))
            }
            navigationItem.rightBarButtonItems = [voiceBtn,imageBtn]
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
        imageBtn.isEnabled = false
    }
    
    //     image only add in textview
    func textViewDidBeginEditing(_ textView: UITextView) {
        switchBetweenTextFieldAndTextView()
        imageBtn.isEnabled = true
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
        navigationItem.rightBarButtonItems = [voiceBtn,imageBtn]
    }
    
    //    MARK: - SETUP UI
    func setupDelegate(){
        titleTextField.delegate = self
        desTextView.delegate = self
        imagePicker.delegate = self
    }
    
    func setUpNavBarItem() {
        if #available(iOS 13.0, *) {
            voiceBtn = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .plain, target: self, action: #selector(self.voice))
            imageBtn = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(self.addImage))
        } else {
            voiceBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "mic", action:  #selector(self.voice)))
            imageBtn = UIBarButtonItem(customView:  UIImageIO12And13Helper.shared.createBarButtonItem(name: "photo", action:  #selector(self.addImage)))
        }
        
    }
    
    func setupNavBarUI() {
        setUpNavBarItem()
        if mode == "edit" {
            navigationItem.rightBarButtonItems = [voiceBtn ,imageBtn]
        }
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
