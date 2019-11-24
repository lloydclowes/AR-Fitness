//
//  SpeechSynthesizer.swift
//  AR-Sports
//
//  Created by Group 8 on 29/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import AVFoundation


class SpeechSynthesizer : AVSpeechSynthesizer {
    
    let voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
    let speechSynthesizer = AVSpeechSynthesizer()
    let voiceToUse = AVSpeechSynthesisVoice(language: "en-GB")
    var speechUtterance: AVSpeechUtterance = AVSpeechUtterance()
    var rewards = ["Good job!", "Well done!", "Keep up the good work!", "Perfect!", "You're rocking it!", "Keep it up!"]
    
    func speak(statement: String) {
        speechUtterance = AVSpeechUtterance(string: statement)
        speechUtterance.voice = voiceToUse
        speechUtterance.volume = 0.5
        speechSynthesizer.speak(speechUtterance)
    }
    
    func start() {
        speechUtterance = AVSpeechUtterance(string: "Are you ready?")
        speechUtterance.voice = voiceToUse
        speechUtterance.volume = 0.5
        speechSynthesizer.speak(speechUtterance)
        speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.continueSpeaking()
        speechUtterance = AVSpeechUtterance(string: "3")
        speechSynthesizer.speak(speechUtterance)
        speechUtterance = AVSpeechUtterance(string: "2")
        speechSynthesizer.speak(speechUtterance)
        speechUtterance = AVSpeechUtterance(string: "1")
        speechSynthesizer.speak(speechUtterance)
        speechUtterance = AVSpeechUtterance(string: "Go")
        speechSynthesizer.speak(speechUtterance)
    }
    
}
