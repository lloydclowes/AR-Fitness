import Foundation

class HoldingFeedbackGenerator : BaseFeedbackGenerator {
    
    override func started(finished: @escaping () -> Void) {
        speaker.speak(text: "Good. Now get to the hold position.") {
            finished()
        }
    }
    
    override func resume(finished: @escaping () -> Void) {
        speaker.speak(text: "Good recovery!") {
            finished()
        }
    }
    
    override func reached(finished: @escaping () -> Void)  {
        speaker.speak(text: "Nice, now hold it there.") {
           finished()
        }
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        speaker.speak(text: "You completed the challenge!") {
            finished()
        }
    }
    
    override func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: @escaping () -> Void) {
        speaker.speak(text: "Okay, let's try again!") {
            finished()
        }
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
            speaker.speak(text: "Failed. When you're ready, go back to the start position.") {
                finished()
            }
            return
        }
        finished()
    }
    
    private func generateNoStateFeedback(targetName : String, difference: Dictionary<String, EulerAngles>) -> String {
        var diffDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for (joint, _) in difference {
            if feedbackDict[targetName] == nil || feedbackDict[targetName]![joint] == nil {
                continue
            }
            let action = feedbackDict[targetName]![joint]!.action
            let side = feedbackDict[targetName]![joint]!.side
            let name = feedbackDict[targetName]![joint]!.name
            if diffDict.keys.contains(action) {
                if diffDict[action]!.keys.contains(name) {
                    diffDict[action]![name] = "both"
                } else {
                    diffDict[action]![name] = side
                }
            } else {
                diffDict[action] = [name: side]
            }
        }
        
        var feedback = [String]()
        for (action, nameToSides) in diffDict {
            var actionJoints = [String]()
            for (name, sides) in nameToSides {
                var jointFeedback = ""
                if sides == nil {
                    jointFeedback = "your \(name)"
                } else if sides! == "both" {
                    jointFeedback = "both \(name)s"
                } else {
                    jointFeedback = "your \(sides!) \(name)"
                }
                actionJoints.append(jointFeedback)
            }
            feedback.append("\(action) " + spokenListJoin(actionJoints))
        }
        return spokenListJoin(feedback)
    }
}
