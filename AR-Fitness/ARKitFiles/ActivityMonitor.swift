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
    
    let inCoachingMode : Bool
    var firstInstr : Bool
    var times = 0
    let coachingInfo : CoachModeDetail?

    // TODO: Tune this (as low as possible)
    let turningPointTolerance = Float(1.5)
    var stillTurning = false
    var startedTurning = TimeInterval(0)
    
    var started = false
    
    let startState : TargetState
    let targetStates : [TargetState]
    var currentState = ActivityState()
    var prevState = ActivityState()
    
    var stateSuccesses = [StateSuccess]()
    
    var index = -1
    var lastIndex = 0
    var lastArrived = TimeInterval()
    var targetIndex = 0
    var repCount = 0
    
    let speaker = SpeechService.shared
    
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
        get { return max(0, targetStates[lastIndex].duration - stateSuccesses[lastIndex].duration) }
    }
    
    init() {
        self.startState = TargetState("START")
        self.targetStates = []
        self.inCoachingMode = false
        self.coachingInfo = nil
        self.firstInstr = false
    }

    init(start : TargetState, states : [TargetState], coachingMode : Bool = false, coachingInfo : CoachModeDetail? = nil) {
        self.startState = start
        self.targetStates = states
        self.firstInstr = coachingMode
        self.targetIndex = targetStates.count > 1 ? 1 : 0
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
            print("success")
            if repCount % 3 == 1 {
                speaker.speak(statement: SpeechSynthesizer.rewards.randomElement()!)
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
            if currentState.reaches(startState) {
                print("START")
                started = true
                index = 0
            }
            return
        }
        
        let curTime = Date().timeIntervalSince1970
        
        // If the index hasn't changed then ignore
        if index != -1 && currentState.reaches(targetStates[index]) {
            lastArrived = curTime
            stateSuccesses[index].duration += delta
//            print("remain")
            return
        }

        // If we returned to the same state as before, resume
        if index == -1 && currentState.reaches(targetStates[lastIndex]) {
            index = lastIndex
            if curTime - lastArrived > 0.1 && index == 0 {
                completeRep()
            }
            lastArrived = curTime
            print("return to \(index)")
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
            if currentState.getMaxSpeed() > 30 {
                print("TOO FAST!!")
            }
            if stillTurning {
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
            stateSuccesses[index].duration += delta
            if index < lastIndex {
                completeRep()
            }
            
            lastIndex = index
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
                lastArrived = curTime
                targetIndex = (index + 1) % targetStates.count
                
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
//            print("-- start --")
            for joint in targetStates[targetIndex].jointAngles.keys {
                if !difference.keys.contains(joint) {
//                    print("reached \(joint)")
                    stateSuccesses[targetIndex].jointFailures.remove(joint)
                } else {
//                    print("d_\(joint): \(difference[joint]!)")
                }
            }
//            print("-- end --")
        }
    }
}
