//
//  ActivityMonitor.swift
//  AR-Sports
//
//  Created by Brandon Forbes on 21/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import Foundation
import ARKit

class ActivityMonitor {
    
    let useTurningPoints : Bool
    let inCoachingMode : Bool
    var firstInstr : Bool
    var times = 0
    let coachingInfo : CoachModeDetail?

    // TODO: Tune this (as low as possible)
    let turningPointTolerance = Float(1.5)
    var stillTurning = false
    var startedTurning = TimeInterval(0)
    
    var started = false
    
    let targetStates : [TargetState]
    var currentState = ActivityState()
    var prevState = ActivityState()
    
    var stateSuccesses = [StateSuccess]()
    
//    var feedback : [String]
//    var durations : [Double]
    
    var index = -1
    var lastIndex = 0
    var targetIndex = 0
    var repCount = 0
    
    let speaker = SpeechSynthesizer.globalSpeaker
    
    var lastFeedback = TimeInterval()
    
    var targetStateName : String {
        get { return targetStates[targetIndex].name }
    }
    
    var lastStateName : String {
        get { return targetStates[lastIndex].name }
    }
    
    var currentStateName : String {
        get { return index != -1 ? targetStates[index].name : "None" }
    }
    
    var remainingDuration : Double {
        get { /* return max(0, targetStates[lastIndex].duration - durations[lastIndex]) */
            return max(0, targetStates[lastIndex].duration - stateSuccesses[lastIndex].duration)
        }
    }
    
    init() {
        self.targetStates = []
        self.useTurningPoints = false
        self.inCoachingMode = false
        self.coachingInfo = nil
        self.firstInstr = false
                
//        self.durations = []
//        self.feedback = []
    }

    init(_ targetStates : [TargetState], useTurningPoints : Bool = false, coachingMode : Bool = false, coachingInfo : CoachModeDetail? = nil) {
        self.targetStates = targetStates
        self.firstInstr = coachingMode
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.useTurningPoints = useTurningPoints
        self.inCoachingMode = coachingMode
        self.coachingInfo = coachingInfo
        
        for (joint, angles) in targetStates[0].jointAngles {
            let x : Float? = angles.x != nil ? Float(0) : nil
            let y : Float? = angles.y != nil ? Float(0) : nil
            let z : Float? = angles.z != nil ? Float(0) : nil
            // TODO: addAnchor can set the initial angles
            self.currentState.jointAngles[joint] = EulerAngles(x: x, y: y, z: z)
            self.currentState.jointVelocities[joint] = EulerAngles(x: x, y: y, z: z)
        }
        
        for targetState in targetStates {
            self.stateSuccesses.append(StateSuccess(joints: Array(targetState.jointAngles.keys)))
        }
        
//        self.durations = []
//        for _ in 0..<targetStates.count {
//            self.durations.append(0)
//        }
//        self.feedback = []
    }
    
    func restart() {
        started = false
        index = -1
    }
    
    func prettifyJointFailures(state : String, joints : [String]) -> String {
        if joints.count == 0 {
            return "Your joints didn't reach the \(state) state at the same time"
        } else {
            return "Your \(spokenListJoin(joints)) didn't reach the \(state) state"
        }
    }
    
    func completeRep() {
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
            if repCount % 3 == 1 {
                speaker.speak(statement: speaker.rewards.randomElement()!)
            }
            return
        }
        
        if missedStates.count > 0 {
            speaker.speak(statement: spokenListJoin(missedStates))
        }
        
        if shortDurations.count == 1 {
            speaker.speak(statement: "You didn't stay in the \(shortDurations[0]) state for long enough.")
        } else if shortDurations.count > 1 {
            speaker.speak(statement: "You didn't stay in the \(spokenListJoin(shortDurations)) states for long enough.")
        }
        
//        if repSuccess {
//            // Every three reps give feedback
//            if (repCount.isMultiple(of: 3)) {
//                speaker.speak(statement: speaker.rewards.randomElement()!)
//            }
//            repCount += 1
//        } else {
//            let totalFailedJoints = stateFailures.reduce(0, { x, y in x + y.count })
//            if totalFailedJoints == 0 {
//
//            } else if totalFailedJoints > 4 {
//                var missedStates = [String]()
//                for i in 0..<stateFailures.count {
//                    if stateFailures[i].count > 0 {
//                        missedStates.append(targetStates[i].name)
//                    }
//                }
//                speaker.speak(statement: "You didn't reach the " + spokenListJoin(missedStates) + " states.")
//            } else {
//                let spokenJoints = stateFailures.enumerated().map {
//                    prettifyJointFailures(state: targetStates[$0.0].name, joints: Array($0.1))
//                }
//                speaker.speak(statement: spokenListJoin(spokenJoints))
//            }
            
//            feedback = []
//        }
//        repSuccess = true
//        for i in 0..<stateFailures.count {
//            stateFailures[i] = []
//        }
    }
    
    func coachingMode() {
        // Add instructions to exerciseData to be said outloud when reaching a state, so for
        // the target state.
        if currentState.reaches(targetStates[targetIndex]) {
            index = targetIndex
            lastIndex = index
            targetIndex = (targetIndex + 1) % targetStates.count
            print(self.times)
            if firstInstr {
                speaker.speak(statement: " \(coachingInfo!.stateInstructions[targetIndex])")
                self.times = self.times + 1
            }
            
            if self.times >= targetStates.count {
                if firstInstr {
                    speaker.speak(statement: "That was a perfect rep! You're good to go!")
                    self.firstInstr = false
                }
            }
        }
        return
    }
      
    func isTurningPoint() -> (Bool, [String]) {
        var failed = [String]()
        for (joint, velocities) in currentState.jointVelocities {
            if let vcur = velocities.x, let vprev = prevState.jointVelocities[joint]?.x,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                failed.append(joint + ".x was \(abs(vcur))")
            }
            if let vcur = velocities.y, let vprev = prevState.jointVelocities[joint]?.y,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                failed.append(joint + ".y was \(abs(vcur))")
            }
            if let vcur = velocities.z, let vprev = prevState.jointVelocities[joint]?.z,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                failed.append(joint + ".z was \(abs(vcur))")
            }
        }
        return (failed.count == 0, failed)
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) {
        updateState(bodyAnchor, 0.0)
    }
    
    func updateIndex(_ delta : Double) {
        // If we haven't started yet, check if we have reached the start state
        if !started {
            if currentState.reaches(targetStates[0]) {
                print("START")
                started = true
                index = 0
            }
            return
        }
        
        // If the index hasn't changed then ignore
        if index != -1 && currentState.reaches(targetStates[index]) {
//            durations[index] += delta
            stateSuccesses[index].duration += delta
            return
        }

        // If we returned to the same state as before, resume
        if index == -1 && currentState.reaches(targetStates[lastIndex]) {
            print("return to previous")
            index = lastIndex
//            repSuccess = false  TODO: What to put here?
            if index == 0 {
                completeRep()
            }
            return
        }
        
        // Only check state change if we are at a turning point
        let res = isTurningPoint()
        if res.0 {
            if !stillTurning {
                startedTurning = Date().timeIntervalSince1970
                stillTurning = true
            }
        } else {
            if currentState.getMaxSpeed() > 20 {
                print("TOO FAST!!")
            }
            if stillTurning {
//                print("stopped turning")
//                print(res.1)
                stillTurning = false
                index = -1
            }
            return
        }
      
        if (self.inCoachingMode) {
            self.coachingMode()
            return
        }
        
        // If we have reached the target, update state accordingly
        if currentState.reaches(targetStates[targetIndex]) {
            index = targetIndex
            if index < lastIndex {
                completeRep()
            }
            lastIndex = index
            targetIndex = (targetIndex + 1) % targetStates.count
            
            stateSuccesses[index].duration += delta
            
//            durations[index] = 0 // or delta     --- Reset inside completeRep
//            let expectedDuration = targetStates[lastIndex].duration
//            if durations[lastIndex] < expectedDuration {
//                repSuccess = false
//                feedback.append("Stay in \(targetStates[lastIndex].name) state longer")
//            }
            
            print("advanced to \(targetStates[index].name)")
            return
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            if currentState.reaches(targetStates[(targetIndex + i) % targetStates.count]) {
                // Update index variables
                index = (targetIndex + i) % targetStates.count
                if index < lastIndex {
                    completeRep()
                }
                lastIndex = index
                targetIndex = (index + 1) % targetStates.count
                
                stateSuccesses[index].duration += delta
                
                // If we did not arrive back at the last state we reached, add feedback for the missed states
//                if index != lastIndex {
//                    durations[index] = delta
//                    var missed = "Missed: \(targetStates[targetIndex].name)"
//                    for j in 1..<i {
//                        missed += " and " + targetStates[(targetIndex + j) % targetStates.count].name
//                    }
//                    feedback.append(missed)
//
//                    let expectedDuration = targetStates[lastIndex].duration
//                    if durations[lastIndex] < expectedDuration {
//                        feedback.append("You should stay in the \(targetStates[lastIndex].name) state longer.")
//                    }
//                } else {
//                    durations[index] += delta
//                }
//                // The rep was not completed fully since we must have skipped a state
//                repSuccess = false
                
                print("jumped to \(index)")
                return
            }
        }
        
        index = -1
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor, _ delta : Double) {
        prevState = currentState
        let newAngles = bodyAnchor.getBodyJointAngles(Array(currentState.jointAngles.keys))
        currentState.update(newAngles, dema, 1.0)
        
        updateIndex(delta)
        
        let currentTarget = targetStates[targetIndex]
        let difference = currentTarget.jointAngles.difference(currentState.jointAngles, currentTarget.tolerances)
        if inCoachingMode {
    //        let curTime = Date().timeIntervalSince1970
    //        if stillTurning && curTime - startedTurning > 1 && curTime - lastFeedback > 10 {
    //            lastFeedback = Date().timeIntervalSince1970
    //            let currentTarget = targetStates[targetIndex]
    //            let difference = currentTarget.jointAngles.difference(currentState.jointAngles, currentTarget.tolerances)
    //            for (joint, angles) in difference {
    //                if let dx = angles.x {
    //                    if dx > 0 {
    //                        speaker.speak(statement: "Increase x by \(abs(Int(round(dx)))) for: \(joint)")
    //                    } else {
    //                        speaker.speak(statement: "Decrease x by \(abs(Int(round(dx)))) for: \(joint)")
    //                    }
    //                }
    //
    //                if let dy = angles.y {
    //                    if dy > 0 {
    //                        speaker.speak(statement: "Increase y by \(abs(Int(round(dy)))) for: \(joint)")
    //                    } else {
    //                        speaker.speak(statement: "Decrease y by \(abs(Int(round(dy)))) for: \(joint)")
    //                    }
    //                }
    //
    //                if let dz = angles.z {
    //                    if dz > 0 {
    //                        speaker.speak(statement: "Increase z by \(abs(Int(round(dz)))) for: \(joint)")
    //                    } else {
    //                        speaker.speak(statement: "Decrease z by \(abs(Int(round(dz)))) for: \(joint)")
    //                    }
    //                }
    //            }
    //        }
        } else {
            for joint in targetStates[targetIndex].jointAngles.keys {
                if !difference.keys.contains(joint) {
                    stateSuccesses[targetIndex].jointFailures.remove(joint)
                }
            }
        }
    }
}
