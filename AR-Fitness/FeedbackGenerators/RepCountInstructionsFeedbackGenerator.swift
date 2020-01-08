import Foundation

class RepCountInstructionsFeedbackGenerator : RepCountFeedbackGenerator {
    
    override func started(finished: @escaping () -> Void) {
        speaker.speakWithRandomPositivePrefix(text: "Now get to the first state.", completion: finished)
    }
    
    override func advanced(newState: String, finished: @escaping () -> Void) {
        print("advanced")
        lastNextPrompt = curTime
        advancedSpeaking = true
        successSpeaking = false
        speaker.speakWithRandomPositivePrefix(text: "Now the \(newState) state") {
            self.advancedSpeaking = false
            if !self.successSpeaking {
                print("reset lastNext")
                self.lastNextPrompt = TimeInterval()
            }
            finished()
        }
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        print("successs")
        lastNextPrompt = curTime
        successiveReps += 1
        self.successSpeaking = true
        self.advancedSpeaking = false
        if successiveReps > 1 && successiveReps % 3 == 1 {
            speaker.speak(text: "Congratulations! You're ready for the real thing.") {
                self.successSpeaking = false
                if !self.advancedSpeaking {
                    print("reset lastNext")
                    self.lastNextPrompt = TimeInterval()
                }
                finished()
            }
        } else {
            speaker.speakRandomReward() {
                self.successSpeaking = false
                if !self.advancedSpeaking {
                    print("reset lastNext")
                    self.lastNextPrompt = TimeInterval()
                }
                finished()
            }
        }
    }
    
    override func next(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void) {
        print("next")
        if curTime - lastNextPrompt > nextPromptRegularity {
            lastNextPrompt = curTime
            speaker.speak(text: generateNoStateFeedback(targetName: targetName, difference: difference)) {
                finished()
            }
            return
        }
        finished()
    }
    
    override func noState(targetName : String, difference: Dictionary<String, EulerAngles>, finished: @escaping () -> Void) {
        print("nostate")
        if curTime - lastNextPrompt > nextPromptRegularity {
            lastNextPrompt = curTime
            speaker.speak(text: generateNoStateFeedback(targetName: targetName, difference: difference)) {
                finished()
            }
            return
        }
        finished()
    }
}
