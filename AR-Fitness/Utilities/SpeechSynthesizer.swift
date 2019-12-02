//
//  SpeechSynthesizer.swift
//  AR-Sports
//
//  Created by Group 8 on 29/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import AVFoundation


class SpeechSynthesizer {
    
    let rewards = ["Good job!", "Well done!", "Keep up the good work!", "Perfect!", "You're rocking it!", "Keep it up!"]
    
    let speedFocusedStatements = ["Move a bit slower", "Focus on the form, not the speed", "Not so fast!"]
    
    var speechEnabled : Bool
    var volume : Float
    var speechSynthesizer : AVSpeechSynthesizer?
    var voice : AVSpeechSynthesisVoice?
    
    static let globalSpeaker = SpeechSynthesizer(speechEnabled: false)
    
    init(speechEnabled : Bool = true, volume : Float = 0.5) {
        self.speechEnabled = speechEnabled
        self.volume = volume
        self.speechSynthesizer = speechEnabled ? AVSpeechSynthesizer() : nil
        self.voice = speechEnabled ? AVSpeechSynthesisVoice(language: "en-GB") : nil
    }
    
    func enableSpeech() {
        speechEnabled = true
        if speechSynthesizer == nil {
            speechSynthesizer = AVSpeechSynthesizer()
        }
        if voice == nil {
            voice = AVSpeechSynthesisVoice(language: "en-GB")
        }
    }
    
    func disableSpeech() {
        speechEnabled = false
    }
    
    func speak(statement: String) {
        if speechEnabled, let synthesizer = speechSynthesizer {
            synthesizer.speak(makeUtterance(statement: statement))
        }
        print("SPEAKING: " + statement)
    }
    
    func makeUtterance(statement : String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: statement)
        utterance.voice = voice!
        utterance.volume = volume
        return utterance
    }
    
    func countdown() {
        speak(statement: "Are you ready?")
        speak(statement: "3")
        speak(statement: "2")
        speak(statement: "1")
        speak(statement: "GO!")
    }
    
}
