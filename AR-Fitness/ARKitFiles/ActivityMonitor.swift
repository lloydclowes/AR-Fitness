import Foundation
import ARKit

class ActivityMonitor {
    
    let speaker = SpeechService.shared
    
    let noStateThreshold = 0.1
    let retryThreshold = 3.0
    
    let turningPointTolerance : Float = 1.5
    let maxAbsoluteSpeed : Float = 20
    
    let feedbackGenerator : FeedbackGenerator
    
    let liveFeedback : Bool
    let countFirstRep : Bool
    
    let startState : TargetState
    let targetStates : [TargetState]
    
    var hasStarted : Bool!
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
        self.feedbackGenerator = BaseFeedbackGenerator.shared
        self.startState = TargetState("START")
        self.targetStates = []
        self.liveFeedback = false
        self.countFirstRep = false
        self.restart()
    }
    
    init(exercise: Exercise, generator : FeedbackGenerator, liveFeedback : Bool = false, countFirstRep : Bool = false) {
        self.feedbackGenerator = generator
        self.startState = exercise.startState
        self.targetStates = exercise.states
        self.liveFeedback = liveFeedback
        self.countFirstRep = countFirstRep
        self.restart()
    }
    
    func restart() {
        self.hasStarted = false
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
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.repCount = 0
//        self.successCount = 0
    }
    
    func prettifyJointFailures(state : String, joints : [String]) -> String {
        if joints.count == 0 {
            return "Your joints didn't reach the \(state) state at the same time"
        } else {
            return "Your \(spokenListJoin(joints.map(jointToName))) didn't reach the \(state) state"
        }
    }
        
    func completeRep() {
        if !liveFeedback {
            // Find all the states that were never hit and the reason
            var missedStates = [String]()
            for i in 0..<targetStates.count {
                let stateSuccess = stateSuccesses[i]
                if stateSuccess.duration == 0 {
                    missedStates.append(prettifyJointFailures(state: targetStates[i].name, joints: Array(stateSuccess.jointFailures)))
                }
            }
            
            // Find all states that weren't held for long enough
            var shortDurations = [String]()
            for i in 0..<targetStates.count {
                if 0 < stateSuccesses[i].duration && stateSuccesses[i].duration < targetStates[i].duration {
                    shortDurations.append(targetStates[i].name)
                }
            }
            
            // Reset the success structs
            for i in 0..<targetStates.count {
                self.stateSuccesses[i] = StateSuccess(joints: Array(targetStates[i].jointAngles.keys))
            }
            
            // Check for success by no feedback
            if !repTooFast && missedStates.count == 0 && shortDurations.count == 0 {
                repCount += 1
//                successCount += 1
//                if successCount == 1 {
//                    speaker.speak(text: "Better!")
//                }
                print("reps: \(repCount!)")
                return
            }
            
//            successCount = 0
            
            var allFeedback = ""
                        
            // If we missed some states, explain them
            if missedStates.count > 0 {
                allFeedback += spokenListJoin(missedStates) + "."
            }
            
            // Vocalise if the durations were too short
            if shortDurations.count == 1 {
                allFeedback += " You didn't stay in the \(shortDurations[0]) state for long enough."
            } else if shortDurations.count > 1 {
                allFeedback += " You didn't stay in the \(spokenListJoin(shortDurations)) states for long enough."
            }
            
            if repTooFast {
                allFeedback += " " + SpeechService.tooFastStatements.randomElement()!
                repTooFast = false
            }
            
            speaker.speak(text: allFeedback)
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
    
    
    private func started() {
        hasStarted = true
        feedbackGenerator.started()
        print("started")
    }
    
    private func advanceTarget(to : Int) {
        targetIndex = to
        
        if targetIndex == 0 {
            if targetStates.count == 1 {
                complete()
            }
            hitFirstTarget = true
        } else if targetIndex == 1 {
            complete()
        }
        
        feedbackGenerator.advanced()
        print("advanced to \(to)")
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
            feedbackGenerator.completeSuccess()
        } else {
            feedbackGenerator.completeFail(tooFast: repTooFast, missedStates: missedStates, shortStates: shortDurations)
        }
                
        // Reset the success info
        for i in 0..<targetStates.count {
            self.stateSuccesses[i] = StateSuccess(joints: Array(targetStates[i].jointAngles.keys))
        }
        
        repTooFast = false
        
        print("complete. reps: \(repCount!)")
    }
    
    private func retry() {
        stateSuccesses[lastIndex].duration = 0
        if lastIndex == 0 {
            complete()
        }
        feedbackGenerator.retry()
        print("retried")
    }
    
    private func tooFast() {
        repTooFast = true
        feedbackGenerator.tooFast()
        print("too fast: \(currentState.getMaxSpeed())")
    }
    
    private func jump(to : Int) {
        index = to
        lastIndex = index
        lastFeedback = TimeInterval()
        lastArrived = curTime
        print("jumped to \(to)")
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
        
        feedbackGenerator.noState(difference: difference)
        
        if curTime - lastArrived > retryThreshold {
            feedbackGenerator.expired()
        }
        
        print("no state")
    }
    
    func updateIndex(_ delta : Double) {
        
        // If the exercise has terminated, don't update
        if paused {
            return
        }
        
        // If we haven't started yet, check if we have reached the start state
        if !hasStarted {
            if currentState.reaches(startState) {
                started()
            }
            return
        }
                
        // If the index hasn't changed then ignore
        if index != -1 && currentState.reaches(targetStates[index]) {
            lastArrived = curTime
            lastFeedback = TimeInterval()
            stateSuccesses[index].duration += delta
            // If we have completed this state, move target
            if index == targetIndex && stateSuccesses[index].duration > targetStates[index].duration {
                advanceTarget(to: (targetIndex + 1) % targetStates.count)
            }
//            print("remain")
            return
        }

        // If we returned to the same state as before, resume
        if index == -1 && lastIndex != -1 && currentState.reaches(targetStates[lastIndex]) {
            print("returning")
//            index = lastIndex
            if curTime - lastArrived > noStateThreshold {
                stateSuccesses[lastIndex].duration = floor(stateSuccesses[lastIndex].duration)
                if curTime - lastArrived > retryThreshold {
                    retry()
                }
            }
            
            jump(to: lastIndex)
            
//            lastArrived = curTime
//            lastFeedback = TimeInterval()
//            print("return to \(index)")
            return
        }
        
        
        if currentState.getMaxSpeed() > maxAbsoluteSpeed {
            tooFast()
        }
        
        // Only check state change if we are at a turning point
//        if !isTurningPoint() {
//            if currentState.getMaxSpeed() > maxAbsoluteSpeed {
//
//                print("Too fast: \(currentState.getMaxSpeed())")
//                if liveFeedback {
//                    speaker.speakRandomTooFast()
//                } else {
//                    repTooFast = true
//                }
//            }
//            index = -1
//            return
//        }
      
        // If we have reached the target, update state accordingly
        if currentState.reaches(targetStates[targetIndex]) {
//            index = targetIndex
            print("advancing")
            jump(to: targetIndex)
            advanceTarget(to: (targetIndex + 1) % targetStates.count)
            return
                
//            stateSuccesses[index].duration += delta
//            if index < lastIndex || countFirstRep && lastIndex == -1 && index == 0 {
//                completeRep()
//            }
            
//            lastIndex = index
//            lastFeedback = TimeInterval()
//            lastArrived = curTime
//            targetIndex = (targetIndex + 1) % targetStates.count
            
//            print("advanced to \(targetStates[index].name)")
//            return
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            let newIndex = (targetIndex + i) % targetStates.count
            if currentState.reaches(targetStates[newIndex]) {
                // Update index variables
                jump(to: newIndex)
                advanceTarget(to: newIndex + 1)
                return
//                index = (targetIndex + i) % targetStates.count
//                stateSuccesses[index].duration += delta
//                if index < lastIndex {
//                    completeRep()
//                }
                
//                lastIndex = index
//                lastFeedback = TimeInterval()
//                lastArrived = curTime
//                targetIndex = (index + 1) % targetStates.count
                
//                print("jumped to \(index)")
//                return
            }
        }
                
        noState()
//        index = -1
//        if liveFeedback && curTime - lastArrived > resetTimerThreshold {
//            terminated = true
//            speaker.speak(text: "Sorry you didn't complete the exercise. Better luck next time!") {
//                self.restart()
//            }
//        }
    }
    
    func generateFeedback(difference: Dictionary<String, EulerAngles>) -> String {
        var feedbackDict : Dictionary<String, Dictionary<String, String?>> = [:]
        for (joint, _) in difference {
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
    
    func updateState(_ bodyAnchor : ARBodyAnchor, _ delta : Double) {
        curTime = Date().timeIntervalSince1970

        prevState = currentState
        let newAngles = bodyAnchor.getBodyJointAngles(Array(currentState.jointAngles.keys))
        currentState.update(newAngles, Augmentation.dema, 1.0)
        
        updateIndex(delta)
    }
}
