import Foundation

class RepCountFeedbackGenerator : BaseFeedbackGenerator {
    
    override func started(finished: @escaping () -> Void) {
        speaker.speak(text: "Good. Now hit the reps!") {
            finished()
        }
    }
    
    override func tooFast(finished: @escaping () -> Void) {
        if curTime - lastTooFast > tooFastRegularity {
            lastTooFast = curTime
            speaker.speak(text: "Slow down a bit") {
                finished()
            }
            return
        }
        finished()
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        speaker.speak(text: "Keep it up!") {
            finished()
        }
    }
    
    override func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: @escaping () -> Void) {
        
        let fastMessage = tooFast ? "You moved too quickly" : ""
        
        var missed = [String]()
        for (stateName, joints) in missedStates {
            var stateMessage = "To hit the \(stateName) state you should "
            stateMessage += generateMissedFeedback(stateName: stateName, joints: joints)
            missed.append(stateMessage)
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
    
    private func generateMissedFeedback(stateName : String, joints : Set<String>) -> String {
        var stateDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for joint in joints {
            if feedbackDict[stateName] == nil || feedbackDict[stateName]![joint] == nil {
                continue
            }
            let action = feedbackDict[stateName]![joint]!.action
            let side = feedbackDict[stateName]![joint]!.side
            let name = feedbackDict[stateName]![joint]!.name
            if stateDict.keys.contains(action) {
                if stateDict[action]!.keys.contains(name) {
                    stateDict[action]![name] = "both"
                } else {
                    stateDict[action]![name] = side
                }
            } else {
                stateDict[action] = [name: side]
            }
        }
        
        var feedback = [String]()
        for (action, nameToSides) in stateDict {
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
