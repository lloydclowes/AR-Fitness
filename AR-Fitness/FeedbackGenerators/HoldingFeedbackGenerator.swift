import Foundation

class HoldingFeedbackGenerator : BaseFeedbackGenerator {
    
    override func started(startMsg: String, finished: @escaping () -> Void) {
        speaker.speakWithRandomPositivePrefix(text: "Now get to the hold position.", completion: finished)
    }
    
    override func resume(finished: @escaping () -> Void) {
        lastNextPrompt = TimeInterval()
        speaker.speakRandomRecovery(completion: finished)
    }
    
    override func reached(finished: @escaping () -> Void)  {
        speaker.speakWithRandomPositivePrefix(text: "Now hold it there.", completion: finished)
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        speaker.speakWithRandomCompletionPrefix(text: "You completed the challenge.", completion: finished)
    }
    
    override func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: @escaping () -> Void) {
        speaker.speakWithRandomNegativePrefix(text: "Let's try again.", completion: finished)
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
    
    override func expired(finished: @escaping () -> Void) {
        if curTime - lastExpired > expiredRegularity {
            lastExpired = curTime
            speaker.speakWithRandomNegativePrefix(text: "When you're ready, go back to the start position.", completion: finished)
            return
        }
        finished()
    }
}
