//
//  Alertable.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 2/24/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//
//voice1

import Foundation
import UIKit


//validate passcode to lock
public enum PasscodeValidationError: String {
    case wrong = "Wrong Passcode"
}

//set up passcode
public enum PasscodeMessage: String {
    case storePasscode =  "Passcode successfully stored"
    case updatePasscode = "Passcode successfully updated"
    case emptyPasscode = "Passcode can not empty"
    case invalidConfirm = "Passcode and confirm passcode does not match"
}

public enum alertTitle: String {
    case passcodeSetup = "Passcode Setup"
    case passcodeValidation = "Passcode Validation"
}

public protocol Alertable {}

public extension Alertable where Self: UIViewController {
    
    func showAlert(title: alertTitle, message: PasscodeValidationError, preferredStyle: UIAlertController.Style = .alert, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
    func showStoredPasscodeAlert(goBackPreviousView: Bool, title: alertTitle, message: PasscodeMessage) {
        let alert = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            if goBackPreviousView {
                self.navigationController?.popViewController(animated: true)
            }
        }
        ))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showAlertWithInputStringForSearch(title: String,searchController: UISearchController) {
        let voiceViewModel = VoiceViewModel()
        voiceViewModel.startRecordingWithAlert()
        
        voiceViewModel.alert = UIAlertController(title: title, message: "Say something, I'm listening", preferredStyle: .alert)
        voiceViewModel.alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            voiceViewModel.stopRecording()
            
        }))
        voiceViewModel.alert.addAction(UIAlertAction(title: "OK",style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            voiceViewModel.stopRecording()
            searchController.searchBar.text = voiceViewModel.alert.message
        }))
        self.present(voiceViewModel.alert, animated: true)
    }
    
    
    func showAlertWithInputStringForPasscode(title: String,textField: UITextField) {
        let voiceViewModel = VoiceViewModel()
        voiceViewModel.startRecordingWithAlert()
        
        voiceViewModel.alert = UIAlertController(title: title, message: "Say something, I'm listening", preferredStyle: .alert)
        voiceViewModel.alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            voiceViewModel.stopRecording()
            
        }))
        voiceViewModel.alert.addAction(UIAlertAction(title: "OK",style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            voiceViewModel.stopRecording()
            textField.text = voiceViewModel.alert.message
        }))
        self.present(voiceViewModel.alert, animated: true)
    }
//    
//    func showAlertWithInputStringForPasscode(title: String, tf: UITextField?) {
//        let voiceViewModel = VoiceViewModel()
//        voiceViewModel.startRecordingWithAlert()
//        
//        voiceViewModel.alert = UIAlertController(title: title, message: "Say something, I'm listening", preferredStyle: .alert)
//        voiceViewModel.alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
//            voiceViewModel.stopRecording()
//            
//        }))
//        voiceViewModel.alert.addAction(UIAlertAction(title: "OK",style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
//            voiceViewModel.stopRecording()
//            tf!.text = voiceViewModel.alert.message
//        }))
//        self.present(voiceViewModel.alert, animated: true)
//    }
}

