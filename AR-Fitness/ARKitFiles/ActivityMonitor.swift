import Foundation
import ARKit

class ActivityMonitor {
    
    let speaker = SpeechService.shared
    
    let noStateThreshold = 0.15
    let retryThreshold = 3.0
    
    let turningPointTolerance : Float = 1.5
    let maxAbsoluteSpeed : Float = 20

    let startPromptDuration = 10.0
    
    let feedbackGenerator : FeedbackGenerator
    
    let countFirstRep : Bool
    
    let exerciseType : ExerciseType
    
    let startState : TargetState
    let targetStates : [TargetState]
    
    var startReached : Bool!
    var ready : Bool!
    
    var paused : Bool!
    var hitFirstTarget : Bool!
    
    var currentState : ActivityState!
    var prevState : ActivityState!
    
    var stateSuccesses : [StateSuccess]!
    var repTooFast : Bool!
//    var successCount : Int!
    
    var index : Int!
    var lastIndex : Int!
    var targetIndex : Int!
    var repCount : Int!
    
    var curTime : TimeInterval!
    var lastStartPrompt : TimeInterval!
    
    var lastArrived : TimeInterval!
    
    var lastFeedback : TimeInterval!
    
    var targetStateName : String {
        get { return targetStates[targetIndex].name }
    }
    
    var lastStateName : String {
        get { return lastIndex != -1 ? targetStates[lastIndex].name : "None" }
    }
    
    var currentStateName : String {
        get { return index != -1 ? targetStates[index].name : "None" }
    }
    
    var remainingDuration : Double {
        get {
            if lastIndex == -1 {
                return targetStates[0].duration
            } else {
                return max(0, targetStates[lastIndex].duration - stateSuccesses[lastIndex].duration)
            }
        }
    }
    
    var fullDuration : Double {
        get { return targetStates[targetIndex].duration }
    }
    
    init() {
        self.feedbackGenerator = PrintingFeedbackGenerator.shared
        self.startState = TargetState("START")
        self.targetStates = []
        self.countFirstRep = false
        self.exerciseType = .rep
        self.restart()
    }
    
    init(exercise : Exercise, feedbackGenerator : FeedbackGenerator, countFirstRep : Bool = false) {
        self.feedbackGenerator = feedbackGenerator
        self.startState = exercise.startState
        self.targetStates = exercise.states
        self.countFirstRep = countFirstRep
        self.exerciseType = exercise.type
        self.restart()
    }
    
    func restart() {
        self.startReached = false
        self.ready = false
        self.paused = false
        self.hitFirstTarget = false
        
        self.currentState = ActivityState()
        for (joint, angles) in targetStates[0].jointAngles {
            let x : Float? = angles.x != nil ? Float(0) : nil
            let y : Float? = angles.y != nil ? Float(0) : nil
            let z : Float? = angles.z != nil ? Float(0) : nil
            // TODO: addAnchor can set the initial angles
            self.currentState.jointAngles[joint] = EulerAngles(x: x, y: y, z: z)
            self.currentState.jointVelocities[joint] = EulerAngles(x: x, y: y, z: z)
        }
        self.prevState = ActivityState()
        
        self.stateSuccesses = []
        for targetState in targetStates {
            self.stateSuccesses.append(StateSuccess(joints: Array(targetState.jointAngles.keys)))
        }
        
        self.repTooFast = false
        
        self.index = -1
        self.lastIndex = -1
        self.lastArrived = TimeInterval()
        self.lastStartPrompt = TimeInterval()
        self.targetIndex = 0
        self.repCount = 0
    }
    
    func prettifyJointFailures(state : String, joints : [String]) -> String {
        if joints.count == 0 {
            return "Your joints didn't reach the \(state) state at the same time"
        } else {
            return "Your \(spokenListJoin(joints.map(jointToName))) didn't reach the \(state) state"
        }
    }
      
    func isTurningPoint() -> Bool {
        for (joint, velocities) in currentState.jointVelocities {
            if let vcur = velocities.x, let vprev = prevState.jointVelocities[joint]?.x,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                return false
            }
            if let vcur = velocities.y, let vprev = prevState.jointVelocities[joint]?.y,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                return false
            }
            if let vcur = velocities.z, let vprev = prevState.jointVelocities[joint]?.z,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                return false
            }
        }
        return true
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) {
        updateState(bodyAnchor, 0.0)
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor, _ delta : Double) {
        curTime = Date().timeIntervalSince1970

        prevState = currentState
        let newAngles = bodyAnchor.getBodyJointAngles(Array(currentState.jointAngles.keys))
        
        if currentState == ActivityState() {
            currentState.jointAngles = newAngles
        } else if prevState == ActivityState() {
            prevState = currentState
            currentState.jointAngles = newAngles
        } else {
            currentState.update(newAngles, Augmentation.dema, 1.0)
        }
            
        updateIndex(delta)
    }
    
//    private func started() {
//        if !speakingStart {
//            speakingStart = true
//            speaker.speak(text: "") {
//                self.speakingStart = false
//                self.hasStarted = true
//            }
//        }
//    }
    
    private func advanceTarget(to : Int) {
        if to == 1 || to == 0 && targetStates.count == 1 {
            complete()
        }
        
        hitFirstTarget = true
        
        if targetIndex == to {
            return
        }
        
        targetIndex = to
        if targetIndex != 1  {
            paused = true
            feedbackGenerator.advanced() {
                self.paused = false
            }
        }
    }
    
    private func complete() {
        if !hitFirstTarget && !countFirstRep {
            print("complete - ignore")
            return
        }
        
        // Find all the states that were never hit and the reason
        var missedStates : Dictionary<String, Set<String>> = [:]
        for i in 0..<targetStates.count {
            let stateSuccess = stateSuccesses[i]
            if stateSuccess.duration == 0 {
                missedStates[targetStates[i].name] = stateSuccess.jointFailures
            }
        }
        
        // Find all states that weren't held for long enough
        var shortDurations = [String]()
        for i in 0..<targetStates.count {
            if 0 < stateSuccesses[i].duration && stateSuccesses[i].duration < targetStates[i].duration {
                shortDurations.append(targetStates[i].name)
            }
        }
        
        // Submit completion to feedback generator
        if !repTooFast && missedStates.count == 0 && shortDurations.count == 0 {
            repCount += 1
            paused = true
            feedbackGenerator.completeSuccess() {
                self.paused = false
            }
        } else {
            paused = true
            feedbackGenerator.completeFail(tooFast: repTooFast, missedStates: missedStates, shortStates: shortDurations) {
                self.paused = false
            }
        }
        
        // TODO:   vv or similar
        // if exercise.type == .hold {
        //     restart()
        // }
        
        // Reset the success info
        for i in 0..<targetStates.count {
            self.stateSuccesses[i] = StateSuccess(joints: Array(targetStates[i].jointAngles.keys))
        }
        
        repTooFast = false
        
        print("reps: \(repCount!)")
    }
    
    private func resume() {
        feedbackGenerator.resume() {}
    }
    
    private func tooFast() {
        repTooFast = true
        feedbackGenerator.tooFast() {}
//        print("too fast: \(currentState.getMaxSpeed())")
    }
    
    private func jump(to : Int) {
        index = to
        lastIndex = index
        lastFeedback = TimeInterval()
        lastArrived = curTime
//        print("jumped to \(to)")
    }
    
    private func noState() {
        index = -1
        if curTime - lastArrived <= noStateThreshold {
            return
        }
        
        // use    isTurningPoint()      ??????
        let currentTarget = targetStates[targetIndex]
        let difference = currentTarget.jointAngles.difference(currentState.jointAngles, currentTarget.tolerances)
        for joint in targetStates[targetIndex].jointAngles.keys {
            if !difference.keys.contains(joint) {
                stateSuccesses[targetIndex].jointFailures.remove(joint)
            }
        }
        
        feedbackGenerator.noState(targetName: targetStates[targetIndex].name, difference: difference.jointAngles) {}
        
        if exerciseType == .hold && curTime - lastArrived > retryThreshold {
            feedbackGenerator.expired() {}
            restart()
        }
        
//        print("no state")
    }
    
    private func updateIndex(_ delta : Double) {
        
        // If the exercise has terminated, don't update
        if paused {
            return
        }
        
        if !startReached {
            if currentState.reaches(startState) {
                self.startReached = true
                self.lastArrived = curTime
                feedbackGenerator.started {
                    self.ready = true
                }
                return
            }
            if curTime - lastStartPrompt > startPromptDuration {
                lastStartPrompt = curTime
                speaker.speak(text: "Please assume the start position.")
            }
            return
        }
        
        if !ready {
            return
        }
                
        // If the index hasn't changed then ignore
        if index != -1 && currentState.reaches(targetStates[index]) {
            lastArrived = curTime
            lastFeedback = TimeInterval()
            stateSuccesses[index].duration += delta
            // If we have completed this state, move target
            if index == targetIndex {
                if stateSuccesses[index].duration > targetStates[index].duration {
                    advanceTarget(to: (targetIndex + 1) % targetStates.count)
                } else {
                    feedbackGenerator.stay() {}
                }
            } else {
                let currentTarget = targetStates[targetIndex]
                let difference = currentTarget.jointAngles.difference(currentState.jointAngles, currentTarget.tolerances)
                feedbackGenerator.next(targetName: currentTarget.name, difference: difference.jointAngles) {}
            }
            return
        }

        // If we returned to the same state as before, resume
        if index == -1 && lastIndex != -1 && currentState.reaches(targetStates[lastIndex]) {
//            print("returning")
            if curTime - lastArrived > noStateThreshold {
                stateSuccesses[lastIndex].duration = floor(stateSuccesses[lastIndex].duration)
                if exerciseType == .hold && curTime - lastArrived <= retryThreshold {
                    resume()
                } else {
                    advanceTarget(to: targetIndex)
                }
            }
            
            jump(to: lastIndex)
            return
        }
        
        
        if currentState.getMaxSpeed() > maxAbsoluteSpeed {
            tooFast()
        }
        
        // If we have reached the target, update state accordingly
        if currentState.reaches(targetStates[targetIndex]) {
//            print("advancing")
            jump(to: targetIndex)
            return
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            let newIndex = (targetIndex + i) % targetStates.count
            if currentState.reaches(targetStates[newIndex]) {
                // Update index variables
                jump(to: newIndex)
                advanceTarget(to: (newIndex + 1) % targetStates.count)
                return
            }
        }
                
        noState()
    }
    
    private func generateFeedback(difference: Dictionary<String, EulerAngles>) -> String {
        var feedbackDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for (joint, _) in difference {

            if targetStates[targetIndex].feedback[joint] == nil {
                continue
            }

            let action = targetStates[targetIndex].feedback[joint]!.action
            let side = targetStates[targetIndex].feedback[joint]!.side
            let name = targetStates[targetIndex].feedback[joint]!.name
            if feedbackDict.keys.contains(action) {
                if feedbackDict[action]!.keys.contains(name) {
                    feedbackDict[action]![name] = "both"
                } else {
                    feedbackDict[action]![name] = side
                }
            } else {
                feedbackDict[action] = [name: side]
            }
        }
        
        var feedback = [String]()
        for (action, nameToSides) in feedbackDict {
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
