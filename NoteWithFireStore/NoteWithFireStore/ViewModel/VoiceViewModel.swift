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

public class VoiceViewModel: NSObject, SFSpeechRecognizerDelegate {
    static let shared =  VoiceViewModel()
    private override init() {}
    
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier:"en-us"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var subStr1 = ""
    var subStr2 = ""
    
    var alert = UIAlertController()
    
//    provice authorize
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
            @unknown default:
                fatalError()
            }
            
        }
    }
    
    
    fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
    }
    
//    stop record
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
    
    
//    prepare audio to start record
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
    
    
//    start record for note
    func startRecording(titleTextField: UITextField, desTextView: UITextView) {
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
                let voiceText = self.subStr1 + res.bestTranscription.formattedString
                print(bestStr)
                
                if titleTextField.isFirstResponder {
                    titleTextField.text = bestStr
                    
                    let positionOriginal = titleTextField.beginningOfDocument
                    let cursorLocation = titleTextField.position(from: positionOriginal, offset: (voiceText.count))
                    if let cursorLocation = cursorLocation {
                        titleTextField.selectedTextRange = titleTextField.textRange(from: cursorLocation, to: cursorLocation)
                    }
                } else {
                    desTextView.text = bestStr
                    let positionOriginal = desTextView.beginningOfDocument
                    let cursorLocation = desTextView.position(from: positionOriginal, offset: (voiceText.count))
                    if let cursorLocation = cursorLocation {
                        desTextView.selectedTextRange = desTextView.textRange(from: cursorLocation, to: cursorLocation)
                    }
                }
                
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
    

//    record voice to text for textfield and textview
//    audiEngine running => stop , else => start
    func clickRecordBtn(titleTextField: UITextField, desTextView: UITextView, viewController: UIViewController ) {
        if audioEngine.isRunning {
            stopRecording()
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
                viewController.view.endEditing(true)
            }
            
            let selectedIndex = text.index(text.startIndex, offsetBy: cursorPosition)
            subStr1 = String(text[text.startIndex..<selectedIndex])
            subStr2 = String(text[selectedIndex..<text.endIndex])
            
            startRecording(titleTextField: titleTextField, desTextView: desTextView)
            
        }
    }
    
//    record keywords to search
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
    
    
   
}
