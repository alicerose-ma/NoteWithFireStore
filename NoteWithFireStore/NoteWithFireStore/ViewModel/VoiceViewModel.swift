//
//  VoiceViewModel.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 3/13/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//

import Foundation
import UIKit
import Speech

class VoiceViewModel: NSObject, SFSpeechRecognizerDelegate  {
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier:"en-us"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var subStr1 = ""
    var subStr2 = ""
    
    var alert = UIAlertController()
    
    func voiceSetup(recordOutlet: UIButton) {
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
                recordOutlet.isEnabled = buttonState
            }
        }
    }
    
    
    func voiceSetupWithoutRecordBtn() {
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
        }
    }
    
    
    fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
    
    
    func prepareAudioSession() {
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
    }
    
    func startRecording(titleTextField: UITextField, desTextView: UITextView, recordOutlet: UIButton) {
        prepareAudioSession()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() //read from buffer
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        
        // Configure the microphone input.
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
                
                let bestStr = self.subStr1 + res.bestTranscription.formattedString +  " " + self.subStr2
            
                if titleTextField.isFirstResponder {
                    titleTextField.text = bestStr
                } else {
                    desTextView.text = bestStr
                }
                
                isLast = (res.isFinal)
            }
            
            if err != nil || isLast {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                recordOutlet.setTitle("Record", for: .normal)
                print("Recording stopped")
            }
        }
    }
    
    
    func clickRecordBtn(titleTextField: UITextField, desTextView: UITextView, recordOutlet: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            recordOutlet.setTitle("Record", for: .normal)
        } else {
            
            var cursorPosition = 0
            var text = ""
            
            if titleTextField.isFirstResponder {
                if let selectedRange = titleTextField.selectedTextRange {
                    cursorPosition = titleTextField.offset(from: titleTextField.beginningOfDocument, to: selectedRange.start)
                }
                text = titleTextField.text!
            } else {
                if let selectedRange = desTextView.selectedTextRange {
                    cursorPosition = desTextView.offset(from: desTextView.beginningOfDocument, to: selectedRange.start)
                }
                text = desTextView.text!
            }
            
            let selectedIndex = text.index(text.startIndex, offsetBy: cursorPosition)
            subStr1 = String(text[text.startIndex..<selectedIndex])
            subStr2 = String(text[selectedIndex..<text.endIndex])
            
            recordOutlet.setTitle("Stop", for: .normal)
            startRecording(titleTextField: titleTextField, desTextView: desTextView, recordOutlet: recordOutlet )
            
        }
    }
    
    
    func startRecordingWithAlert() {
        prepareAudioSession()
        
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() //read from buffer
        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        
        // Configure the microphone input.
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
                let bestStr = res.bestTranscription.formattedString
                self.alert.message = bestStr
                isLast = (res.isFinal)
            }
            
            if err != nil || isLast {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                print("Recording stopped")
            }
        }
    }
    
    
    func startRecordingForPasscode(textField: UITextField) {
           prepareAudioSession()
           
           recognitionRequest = SFSpeechAudioBufferRecognitionRequest() //read from buffer
           let inputNode = audioEngine.inputNode
           
           guard let recognitionRequest = recognitionRequest else {
               fatalError("Could not create request instance")
           }
           
           // Configure the microphone input.
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
                   let bestStr =  res.bestTranscription.formattedString
                   textField.text = bestStr
                   isLast = (res.isFinal)
               }
               
               if err != nil || isLast {
                   self.audioEngine.stop()
                   inputNode.removeTap(onBus: 0)
                   
                   self.recognitionRequest = nil
                   self.recognitionTask = nil
                   
                   print("Recording stopped")
               }
           }
       }

}
