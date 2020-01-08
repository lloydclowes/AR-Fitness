import Foundation

class HoldingInstructionsFeedbackGenerator : HoldingFeedbackGenerator {
        
    override func completeSuccess(finished: @escaping () -> Void) {
        speaker.speakWithRandomCompletionPrefix(text: "You're ready for the real thing!", completion: finished)
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
}
