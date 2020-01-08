import Foundation

class PrintingFeedbackGenerator : BaseFeedbackGenerator {
    
    static let shared = PrintingFeedbackGenerator(feedbackDict: [:])
    
    override func started(finished: @escaping () -> Void) {
        print("started")
        finished()
    }
    
    override func advanced(newState: String, finished: @escaping () -> Void) {
        print("advanced to " + newState)
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
        if curTime - lastNextPrompt > nextPromptRegularity {
            lastNextPrompt = curTime
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
}
