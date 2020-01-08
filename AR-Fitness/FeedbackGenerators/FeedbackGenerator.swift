import Foundation

protocol FeedbackGenerator {
    
    func started(finished: @escaping () -> Void)
    func reached(finished: @escaping () -> Void)
    func advanced(newState: String, finished: @escaping () -> Void)
    func completeSuccess(finished: @escaping () -> Void)
    func completeFail(tooFast: Bool, missedStates: Dictionary<String, Set<String>>, shortStates: [String], finished: @escaping () -> Void)
    func jumped(to : Int, finished: @escaping () -> Void)
    func resume(finished: @escaping () -> Void)
    func tooFast(finished: @escaping () -> Void)
    func stay(finished : @escaping () -> Void)
    func next(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void)
    func noState(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void)
    func expired(finished: @escaping () -> Void)
    
}

class BaseFeedbackGenerator : FeedbackGenerator {
        
    let speaker = SpeechService.shared
    
    let feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>>
    
    let tooFastRegularity : TimeInterval
    let stayRegularity : TimeInterval
    let nextPromptRegularity : TimeInterval
    let expiredRegularity : TimeInterval
    
    var lastTooFast = TimeInterval()
    var lastStay = TimeInterval()
    var lastNextPrompt = TimeInterval()
    var lastExpired = TimeInterval()

    internal var curTime : TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    init(feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>>,
         tooFastRegularity : TimeInterval = 1,
         stayRegularity : TimeInterval = 5,
         nextPromptRegularity : TimeInterval = 5,
         expiredRegularity : TimeInterval = 13) {
        self.feedbackDict = feedbackDict
        self.tooFastRegularity = tooFastRegularity
        self.stayRegularity = stayRegularity
        self.nextPromptRegularity = nextPromptRegularity
        self.expiredRegularity = expiredRegularity
    }
    
    func started(finished: @escaping () -> Void) {
        finished()
    }
    
    func reached(finished: @escaping () -> Void)  {
        finished()
    }
    
    func advanced(newState: String, finished: @escaping () -> Void)  {
           finished()
    }
    
    func completeSuccess(finished: @escaping () -> Void) {
           finished()
    }
    
    func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: @escaping () -> Void) {
           finished()
    }
    
    func jumped(to: Int, finished: @escaping () -> Void)  {
           finished()
    }
    
    func resume(finished: @escaping () -> Void)  {
           finished()
    }
    
    func tooFast(finished: @escaping () -> Void)  {
           finished()
    }
    
    func stay(finished : @escaping () -> Void)  {
           finished()
    }
    
    func next(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void)  {
           finished()
    }

    func noState(targetName : String, difference : Dictionary<String, EulerAngles>, finished: @escaping () -> Void)  {
           finished()
    }
    
    func expired(finished: @escaping () -> Void)  {
           finished()
    }
    
    func generateNoStateFeedback(targetName : String, difference: Dictionary<String, EulerAngles>) -> String {
        var diffDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for (joint, angles) in difference {
            if feedbackDict[targetName] == nil || feedbackDict[targetName]![joint] == nil {
                print("aaa")
                continue
            }
            
//            print(joint)
            
            if let dx = angles.x?.val {
//                print("x")
                let action = feedbackDict[targetName]![joint]!.x!.action[dx > 0 ? 0 : 1]
                let side = feedbackDict[targetName]![joint]!.x!.side
                let name = feedbackDict[targetName]![joint]!.x!.name
                if diffDict.keys.contains(action) {
                    if diffDict[action]!.keys.contains(name) && diffDict[action]![name] != side {
                        diffDict[action]![name] = "both"
                    } else {
                        diffDict[action]![name] = side
                    }
                } else {
                    diffDict[action] = [name: side]
                }
            }
            
            if let dy = angles.y?.val {
//                print("y")
                let action = feedbackDict[targetName]![joint]!.y!.action[dy > 0 ? 0 : 1]
                let side = feedbackDict[targetName]![joint]!.y!.side
                let name = feedbackDict[targetName]![joint]!.y!.name
                if diffDict.keys.contains(action) {
                    if diffDict[action]!.keys.contains(name) && diffDict[action]![name] != side {
                        diffDict[action]![name] = "both"
                    } else {
                        diffDict[action]![name] = side
                    }
                } else {
                    diffDict[action] = [name: side]
                }
            }
            
            if let dz = angles.z?.val {
//                print("z")
                let action = feedbackDict[targetName]![joint]!.z!.action[dz > 0 ? 0 : 1]
                let side = feedbackDict[targetName]![joint]!.z!.side
                let name = feedbackDict[targetName]![joint]!.z!.name
                if diffDict.keys.contains(action) {
                    if diffDict[action]!.keys.contains(name) && diffDict[action]![name] != side {
                        diffDict[action]![name] = "both"
                    } else {
                        diffDict[action]![name] = side
                    }
                } else {
                    diffDict[action] = [name: side]
                }
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
        if feedback.count > 0 {
            print(difference)
        }
        return spokenListJoin(feedback)
    }
    
    func generateMissedFeedback(stateName : String, joints : Set<String>) -> String {
        var stateDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for joint in joints {
            
            if feedbackDict[stateName] == nil || feedbackDict[stateName]![joint] == nil {
                continue
            }
            
            if let fbx = feedbackDict[stateName]?[joint]?.x {
                let action = fbx.action[0]
                let side = fbx.side
                let name = fbx.name
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
            
            if let fby = feedbackDict[stateName]?[joint]?.y {
                let action = fby.action[0]
                let side = fby.side
                let name = fby.name
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
            
            if let fbz = feedbackDict[stateName]?[joint]?.z {
                let action = fbz.action[0]
                let side = fbz.side
                let name = fbz.name
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
