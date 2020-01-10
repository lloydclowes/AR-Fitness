import Foundation

class RepCountInstructionsFeedbackGenerator : RepCountFeedbackGenerator {
    
    override func started(startMsg : String, finished: @escaping () -> Void) {
        speaker.speak(text: startMsg, completion: finished)
    }
    
    override func advanced(newState: String, finished: @escaping () -> Void) {
        lastNextPrompt = curTime
        advancedSpeaking = true
        successSpeaking = false
        speaker.speakWithRandomPositivePrefix(text: "Now the \(newState) state") {
            self.advancedSpeaking = false
            if !self.successSpeaking {
                self.lastNextPrompt = TimeInterval()
            }
            finished()

        }
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        lastNextPrompt = curTime
        successiveReps += 1
        self.successSpeaking = true
        self.advancedSpeaking = false
        if successiveReps > 1 && successiveReps % 3 == 1 {
            speaker.speak(text: "Congratulations! You're ready for the real thing.") {
                self.successSpeaking = false
                if !self.advancedSpeaking {
                    self.lastNextPrompt = TimeInterval()
                }
                finished()
            }
        } else {
            speaker.speakRandomReward() {
                self.successSpeaking = false
                if !self.advancedSpeaking {
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
