import Foundation

/*

func started(finished: () -> Void)
func advanced(finished: () -> Void)
func completeSuccess(finished: () -> Void)
func completeFail(tooFast: Bool, missedStates: Dictionary<String, Set<String>>, shortStates: [String], finished: () -> Void)
func jumped(to : Int, finished: () -> Void)
func retry(finished: () -> Void)
func tooFast(finished: () -> Void)
func noState(targetName : String, difference: Dictionary<String, EulerAngles>, finished: () -> Void)
func expired(finished: () -> Void)

*/

class HoldingFeedbackGenerator : BaseFeedbackGenerator {
    
    override func retry(finished: @escaping () -> Void) {
        print("retry")
        finished()
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
        speaker.speak(text: "You did it!") {
            finished()
        }
    }
    
    override func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: @escaping () -> Void) {
        speaker.speak(text: "Okay, let's try again!") {
            finished()
        }
    }
    
    override func noState(targetName : String, difference: Dictionary<String, EulerAngles>, finished: @escaping () -> Void) {
        if curTime - lastNoState > noStateRegularity {
            lastNoState = curTime
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
            speaker.speak(text: "Failed. When you're ready, try again.") {
                finished()
            }
            return
        }
        finished()
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
