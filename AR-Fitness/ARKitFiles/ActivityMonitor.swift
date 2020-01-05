import Foundation
import ARKit

class ActivityMonitor {
    
    let liveFeedback : Bool
    let countFirstRep : Bool
    
    let noStateThreshold = 0.1
    let resetTimerThreshold = 5.0
    let turningPointTolerance = Float(1.5)   // TODO: Tune this (as low as possible)
    
    var started = false
    var terminated = false
    
    let startState : TargetState
    let targetStates : [TargetState]
    var currentState = ActivityState()
    var prevState = ActivityState()
    
    var stateSuccesses = [StateSuccess]()
    
    var index = -1
    var lastIndex = -1
    var lastArrived = TimeInterval()
    var targetIndex = 0
    var repCount = 0
    
    let speaker = SpeechService.shared
    
    var lastFeedback = TimeInterval()
    let exerciseFeedback : Dictionary<String, JointFeedback>
    
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
        self.startState = TargetState("START")
        self.targetStates = []
        self.liveFeedback = false
        self.countFirstRep = false
        self.exerciseFeedback = [:]
        restart()
    }

    init(exercise: Exercise, liveFeedback : Bool = false, countFirstRep : Bool = false) {
        self.startState = exercise.startState
        self.targetStates = exercise.states
        self.liveFeedback = liveFeedback
        self.countFirstRep = countFirstRep
        self.exerciseFeedback = exercise.feedback
        restart()
    }
    
    func restart() {
        started = false
        terminated = false
        index = -1
        lastIndex = -1
        lastArrived = TimeInterval()
        targetIndex = targetStates.count > 1 ? 1 : 0
        repCount = 0
        
        self.currentState = ActivityState()
        self.prevState = ActivityState()
        for (joint, angles) in targetStates[0].jointAngles {
            let x : Float? = angles.x != nil ? Float(0) : nil
            let y : Float? = angles.y != nil ? Float(0) : nil
            let z : Float? = angles.z != nil ? Float(0) : nil
            // TODO: addAnchor can set the initial angles
            self.currentState.jointAngles[joint] = EulerAngles(x: x, y: y, z: z)
            self.currentState.jointVelocities[joint] = EulerAngles(x: x, y: y, z: z)
        }
        
        self.stateSuccesses = []
        for targetState in targetStates {
            self.stateSuccesses.append(StateSuccess(joints: Array(targetState.jointAngles.keys)))
        }
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
            if missedStates.count == 0 && shortDurations.count == 0 {
                repCount += 1
                print("success")
                if repCount % 3 == 1 {
                    speaker.speakRandomReward()
                }
                return
            }

            if missedStates.count > 0 {
                speaker.speak(text: spokenListJoin(missedStates))
            }
            
            if shortDurations.count == 1 {
                speaker.speak(text: "You didn't stay in the \(shortDurations[0]) state for long enough.")
            } else if shortDurations.count > 1 {
                speaker.speak(text: "You didn't stay in the \(spokenListJoin(shortDurations)) states for long enough.")
            }
        }
    }
      
    func isTurningPoint() -> Bool {
//        var failed = [String]()
        for (joint, velocities) in currentState.jointVelocities {
            if let vcur = velocities.x, let vprev = prevState.jointVelocities[joint]?.x,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
//                failed.append(joint + ".x was \(abs(vcur))")
                return false
            }
            if let vcur = velocities.y, let vprev = prevState.jointVelocities[joint]?.y,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
//                failed.append(joint + ".y was \(abs(vcur))")
                return false
            }
            if let vcur = velocities.z, let vprev = prevState.jointVelocities[joint]?.z,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
//                failed.append(joint + ".z was \(abs(vcur))")
                return false
            }
        }
//        return failed.count == 0
        return true
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) {
        updateState(bodyAnchor, 0.0)
    }
    

    func updateIndex(_ delta : Double) {
        
        // If the exercise has terminated, don't update
        if terminated {
            return
        }
        
        // If we haven't started yet, check if we have reached the start state
        if !started {
            if currentState.reaches(startState) {
                print("START")
                started = true
            }
            return
        }
        
        let curTime = Date().timeIntervalSince1970
        
        // If the index hasn't changed then ignore
        if index != -1 && currentState.reaches(targetStates[index]) {
            lastArrived = curTime
            lastFeedback = TimeInterval()
            stateSuccesses[index].duration += delta
//            print("remain")
            return
        }

        // If we returned to the same state as before, resume
        if index == -1 && lastIndex != -1 && currentState.reaches(targetStates[lastIndex]) {
            index = lastIndex
            if liveFeedback {
                if curTime - lastArrived < resetTimerThreshold {
                    speaker.speak(text: "Okay, now hold it there!")
                }
            } else {
                if curTime - lastArrived > noStateThreshold && index == 0 {
                    completeRep()
                }
            }
            
            lastArrived = curTime
            lastFeedback = TimeInterval()
            print("return to \(index)")
            return
        }
        
        // Only check state change if we are at a turning point
        if !isTurningPoint() {
            if currentState.getMaxSpeed() > 30 {
                print("TOO FAST!")
            }
            index = -1
            return
        }
      
        // If we have reached the target, update state accordingly
        if currentState.reaches(targetStates[targetIndex]) {
            index = targetIndex
            stateSuccesses[index].duration += delta
            if index < lastIndex || countFirstRep && lastIndex == -1 && index == 0 {
                completeRep()
            }
            
            lastIndex = index
            lastFeedback = TimeInterval()
            lastArrived = curTime
            targetIndex = (targetIndex + 1) % targetStates.count
            
            print("advanced to \(targetStates[index].name)")
            return
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            if currentState.reaches(targetStates[(targetIndex + i) % targetStates.count]) {
                // Update index variables
                index = (targetIndex + i) % targetStates.count
                stateSuccesses[index].duration += delta
                if index < lastIndex {
                    completeRep()
                }
                
                lastIndex = index
                lastFeedback = TimeInterval()
                lastArrived = curTime
                targetIndex = (index + 1) % targetStates.count
                
                print("jumped to \(index)")
                return
            }
        }
        
        index = -1
        if liveFeedback && curTime - lastArrived > resetTimerThreshold {
            self.lastArrived = Double.greatestFiniteMagnitude
            terminated = true
            speaker.speak(text: "Sorry you didn't complete the exercise. Better luck next time!") {
                self.restart()
            }
        }
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor, _ delta : Double) {
        prevState = currentState
        let newAngles = bodyAnchor.getBodyJointAngles(Array(currentState.jointAngles.keys))
        currentState.update(newAngles, Augmentation.dema, 1.0)
        
        updateIndex(delta)
        if !started {
            return
        }
        
        let currentTarget = targetStates[targetIndex]
        let difference = currentTarget.jointAngles.difference(currentState.jointAngles, currentTarget.tolerances)
        if liveFeedback {
            
            // CONDITIONS:
            // index == -1                                =>   not in a state
            // isTurningPoint()                           =>   not moving (much)
            // curTime - lastArrived > noStateThreshold   =>   actually left state, not just glitch
            // curTime - lastFeedback > 10                =>   only comment every 10 seconds
            
            let curTime = Date().timeIntervalSince1970
            if index == -1 && isTurningPoint() && curTime - lastFeedback > 10 && curTime - lastArrived > noStateThreshold {
                lastFeedback = Date().timeIntervalSince1970
                var feedback = [String]()
                for (joint, angles) in difference {
                    var jointFeedback = [String]()
                    if let dx = angles.x {
                        if dx > 0 {
                            jointFeedback.append(exerciseFeedback[joint]!.xFeedback!.increase)
                        } else {
                            jointFeedback.append(exerciseFeedback[joint]!.xFeedback!.decrease)
                        }
                    }
    
                    if let dy = angles.y {
                        if dy > 0 {
                            jointFeedback.append(exerciseFeedback[joint]!.yFeedback!.increase)
                        } else {
                            jointFeedback.append(exerciseFeedback[joint]!.yFeedback!.decrease)
                        }
                    }
    
                    if let dz = angles.z {
                        if dz > 0 {
                            jointFeedback.append(exerciseFeedback[joint]!.zFeedback!.increase)
                        } else {
                            jointFeedback.append(exerciseFeedback[joint]!.zFeedback!.decrease)
                        }
                    }
                    
                    feedback.append(spokenListJoin(jointFeedback))
                }
                speaker.speak(text: spokenListJoin(feedback))
            }
        } else {
            for joint in targetStates[targetIndex].jointAngles.keys {
                if !difference.keys.contains(joint) {
                    stateSuccesses[targetIndex].jointFailures.remove(joint)
                }
            }
        }
    }
}
