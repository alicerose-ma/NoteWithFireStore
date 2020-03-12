//
//  CreateNoteViewController.swift
//  note
//
//  Created by Ma Alice on 2/1/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import UIKit
import Speech

enum InputPasscodeCase: String {
    case editPasscode
    case unlockNote
}

class CreateNoteViewController: UIViewController, SetPasscodeDelegate, Alertable, SFSpeechRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate  {
    
    
    //    var activeTextField = UITextField()
    //
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //           self.activeTextField = textField
    //      }
    
    @IBOutlet weak var recordOutlet: UIButton!
    
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier:"en-us"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var subStr1 = ""
    var subStr2 = ""
    
    
    var uniqueID: Int = 0
    var hasLock: Bool = false
    var lockStatus: Bool = false
    
    var insertLockForNoteBtn = UIBarButtonItem()
    var lockStatusBtn = UIBarButtonItem()
    var unlockStatusBtn = UIBarButtonItem()
    
    var createNoteViewModel = CreateNoteViewModel()
    var setPasscodeViewModel = SetPasscodeViewModel()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var lockView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        desTextView.delegate = self
        lockView.isHidden = true
        navBarItemSetUp()
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn]
        voiceSetup()
    }
    
    func navBarItemSetUp() {
        insertLockForNoteBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(addOrRemoveLock))
        lockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(self.lockOFF))
        unlockStatusBtn = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(self.lockON))
    }
    
    @IBAction func enterPasscodeToUnlockBtn(_ sender: Any) {
        setPasscodeViewModel.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let title = titleTextField.text!
        let description = desTextView.text!
        
        if !title.isEmpty || !description.isEmpty {
            // get the current date and time
            let currentDateTime = Date()

            // initialize the date formatter and set the style
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .long

            // get the date time String from the date object
            print(formatter.string(from: currentDateTime)) // October 8, 2016 at 10:48:53 PM
//            print(createdTime)
            

            let noteID = createNoteViewModel.createUniqueNoteDocID(username: createNoteViewModel.username!, uniqueID: uniqueID)
            let note = NoteData(username: createNoteViewModel.username!, id: uniqueID, title: title, des: description, isLocked: lockStatus) //create a new note model with lock
            createNoteViewModel.addNewNote(documentID: noteID, newNote: note)
        }
    }
    
    //    delegate to add lock status
    func addLockIconToNavBar() {
        hasLock = true
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,unlockStatusBtn]
    }
    
    @objc func addOrRemoveLock() {
        showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: hasLock)
    }
    
    func showAddOrRemoveLockOrEditPasscodeActionSheet(hasLock: Bool) {
        let alert = UIAlertController(title: "Lock Note", message: "Select Lock Options" , preferredStyle: .actionSheet)
        
        if hasLock {
            alert.addAction(UIAlertAction(title: "Remove Lock", style: .default, handler: { (_) in
                self.hasLock = false
                self.navigationItem.rightBarButtonItems = [self.insertLockForNoteBtn]
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add Lock", style: .default, handler: { (_) in
                self.hasLock = true
                self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
                    if passcode == "" {
                        self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                    } else {
                        self.addLockIconToNavBar()
                    }
                })
            }))
        }
        
        //        edit passcode action
        self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
            if passcode != "" {
                alert.addAction(UIAlertAction(title: "Edit Passcode", style: .default, handler: { (_) in
                    self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
                        self.enterPasscodeAlert(passcode: passcode, passcodeCase: .editPasscode)
                    })
                }))
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    //    note is locked
    @objc func lockON(){
        lockStatus = true
        lockView.isHidden = false
        navigationItem.rightBarButtonItems = [insertLockForNoteBtn,lockStatusBtn]
        navigationItem.rightBarButtonItems?.first?.isEnabled = false
    }
    
    //    note is unlocked
    @objc func lockOFF() {
        self.setPasscodeViewModel.getUserPasscode(completion: { passcode in
            self.enterPasscodeAlert(passcode: passcode, passcodeCase: .unlockNote)
        })
    }
    
    
    //    enter passcode to edit and unlock
    func enterPasscodeAlert(passcode: String, passcodeCase: InputPasscodeCase) {
        let alert = UIAlertController(title: "Enter Passcode", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Passcode"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
                if password == passcode {
                    switch passcodeCase {
                    case .editPasscode:
                        self.performSegue(withIdentifier: "ShowSetPassView", sender: self)
                    case .unlockNote:
                        self.lockStatus = false
                        self.lockView.isHidden = true
                        self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
                        self.addLockIconToNavBar()
                    }
                } else {
                    self.showAlert(title: .passcodeValidation, message: .wrong)
                }
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetPassView" {
            let destinationVC  = segue.destination as! SetPasscodeViewController
            destinationVC.setPasscodeDelegate = self
        }
    }
    
    
    @IBAction func RecordBtn(_ sender: Any) {
        if audioEngine.isRunning {
            stopRecording()
            recordOutlet.setTitle("Record", for: .normal)
        } else {
            startRecording()
            
            //            let activeTextField
            //
            //            if activeTextField = nil {
            //                activeTextField = desTextView
            //            } else {
            //                activeTextField = view.getSelectedTextField()!
            //            }
            //
            
            
            recordOutlet.setTitle("Stop", for: .normal)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == titleTextField {
            var cursorPosition = 0
            if let selectedRange = titleTextField.selectedTextRange {
                cursorPosition = titleTextField.offset(from: titleTextField.beginningOfDocument, to: selectedRange.start)
                print("\(cursorPosition)")
            }
            
            let text = titleTextField.text!
            let selectedIndex = text.index(text.startIndex, offsetBy: cursorPosition)
            subStr1 = String(text[text.startIndex..<selectedIndex])
            subStr2 = String(text[selectedIndex..<text.endIndex])

        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == desTextView {
            var cursorPosition = 0
            if let selectedRange = desTextView.selectedTextRange {
                cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start)
                print("\(cursorPosition)")
            }
            
            let text = desTextView.text!
            let selectedIndex = text.index(text.startIndex, offsetBy: cursorPosition)
            subStr1 = String(text[text.startIndex..<selectedIndex])
            subStr2 = String(text[selectedIndex..<text.endIndex])

        }
    }
    func startRecording() {
        print("Recording started")
        
        if recognitionTask != nil { //used to track progress of a transcription or cancel it
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue:
                convertFromAVAudioSessionCategory(AVAudioSession.Category.record)), mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() //read from buffer
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) {
            buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Can't start the engine")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { res, err in
            var isLast = false
            if let res = res {
                
                
//                let activeTextField = self.view.getSelectedTextField()!
                if (self.titleTextField.isEditing) {
                    let bestStr = self.subStr1 + res.bestTranscription.formattedString +  " " + self.subStr2
                    self.titleTextField.text = bestStr
                } else {
                    let bestStr = self.subStr1 + res.bestTranscription.formattedString +  " " + self.subStr2
                    self.desTextView.text = bestStr
                }
                
                isLast = (res.isFinal)
                
            }
            
            if err != nil || isLast {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordOutlet.setTitle("Record", for: .normal)
                print("Recording stopped")
            }
        }
    }
    
    fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
    }
    
    fileprivate func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
    
    func voiceSetup() {
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization {
            status in
            var buttonState = false
            switch status {
            case .authorized:
                buttonState = true
                print("Permission received")
            case .denied:
                buttonState = false
                print("User did not give permission to use speech recognition")
            case .notDetermined:
                buttonState = false
                print("Speech recognition not allowed by user")
            case .restricted:
                buttonState = false
                print("Speech recognition not supported on this device")
            }
            DispatchQueue.main.async {
                self.recordOutlet.isEnabled = buttonState
            }
        }
    }
    
}
//
//extension UIView {
//    func getSelectedTextField() -> UITextField? {
//
//        let totalTextFields = getTextFieldsInView(view: self)
//
//        for textField in totalTextFields{
//            if textField.isFirstResponder{
//                return textField
//            }
//        }
//
//        return nil
//
//    }
//
//    func getTextFieldsInView(view: UIView) -> [UITextField] {
//
//        var totalTextFields = [UITextField]()
//
//        for subview in view.subviews as [UIView] {
//            if let textField = subview as? UITextField {
//                totalTextFields += [textField]
//            } else {
//                totalTextFields += getTextFieldsInView(view: subview)
//            }
//        }
//
//        return totalTextFields
//    }
//}


