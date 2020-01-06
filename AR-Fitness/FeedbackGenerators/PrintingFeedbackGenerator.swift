import Foundation

class PrintingFeedbackGenerator : BaseFeedbackGenerator {
    
    static let shared = PrintingFeedbackGenerator(feedbackDict: [:])
    
    override func started(finished: @escaping () -> Void) {
        print("started")
        finished()
    }
    
    override func advanced(finished: @escaping () -> Void) {
        print("advanced")
        finished()
    }
    
    override func completeSuccess(finished: @escaping () -> Void) {
        print("complete - success")
        finished()
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
        
        print(missedMessage)
        print(shortMessage)
        print(fastMessage)
        
        finished()
    }
    
    override func jumped(to: Int, finished: @escaping () -> Void) {
        print("jumped to \(to)")
        finished()
    }
    
    override func resume(finished: @escaping () -> Void) {
        print("resume")
        finished()
    }
    
    override func tooFast(finished: @escaping () -> Void) {
        if curTime - lastTooFast > tooFastRegularity {
            lastTooFast = curTime
            print("too fast")
        }
        finished()
    }
    
    override func noState(targetName : String, difference: Dictionary<String, EulerAngles>, finished: @escaping () -> Void) {
        if curTime - lastNoState > noStateRegularity {
            lastNoState = curTime
            print(generateNoStateFeedback(targetName: targetName, difference: difference))
        }
        finished()
    }
    
    override func expired(finished: @escaping () -> Void) {
        if curTime - lastExpired > expiredRegularity {
            print("expired")
            lastExpired = curTime
        }
        finished()
    }
    
    private func generateMissedFeedback(stateName : String, joints : Set<String>) -> String {
        var stateDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for joint in joints {
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
    
    private func generateNoStateFeedback(targetName : String, difference: Dictionary<String, EulerAngles>) -> String {
        var diffDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for (joint, _) in difference {
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
