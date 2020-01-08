import Foundation

class RepCountFeedbackGenerator : BaseFeedbackGenerator {
    
    override func started(finished: @escaping () -> Void) {
        speaker.speakWithRandomPositivePrefix(text: "Let's get started!", completion: finished)
    }
    
    override func tooFast(finished: @escaping () -> Void) {
        if curTime - lastTooFast > tooFastRegularity {
            lastTooFast = curTime
            speaker.speakRandomTooFast(completion: finished)
            return
        }
        finished()
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        speaker.speakRandomReward(completion: finished)
    }
    
    override func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: @escaping () -> Void) {
        
        let fastMessage = tooFast ? "You moved too quickly" : ""
        
        var missed = [String]()
        for (stateName, joints) in missedStates {
            let stateMessage = "" // "To hit the \(stateName) state you should "
            let fb = generateMissedFeedback(stateName: stateName, joints: joints)
            if fb != "" {
                missed.append(stateMessage + fb)
            }
        }
        let missedMessage = spokenListJoin(missed, delim: ".")
        
        var shortMessage = ""
        if shortStates.count == 1 {
            shortMessage = "You didn't stay long enough in the \(shortStates[0]) state"
        } else if shortStates.count > 1 {
            shortMessage = "You didn't stay long enough in the \(spokenListJoin(shortStates)) states"
        }
        
        speaker.speak(text: missedMessage) {
            self.speaker.speak(text: shortMessage) {
                self.speaker.speak(text: fastMessage) {
                    finished()
                }
            }
        }
    }
}
