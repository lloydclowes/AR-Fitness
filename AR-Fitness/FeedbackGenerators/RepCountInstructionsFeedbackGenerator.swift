import Foundation

class RepCountInstructionsFeedbackGenerator : RepCountFeedbackGenerator {
    
    override func started(finished: @escaping () -> Void) {
        speaker.speakWithRandomPositivePrefix(text: "Now get to the first state.", completion: finished)
    }
    
    override func advanced(newState: String, finished: @escaping () -> Void) {
        lastNextPrompt = TimeInterval()
        lastTooFast = TimeInterval()
        lastExpired = TimeInterval()
        speaker.speakWithRandomPositivePrefix(text: "Now the \(newState) state", completion: finished)
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        successiveReps += 1
        if successiveReps % 3 == 1 {
            speaker.speakRandomReward(completion: finished)
        }
    }
    
    override func next(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void) {
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
