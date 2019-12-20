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
    
    // TODO: Tune this (as low as possible)
    let turningPointTolerance = Float(1.5)
    var stillTurning = false
    var startedTurning = TimeInterval(0)
    
    var started = false
    
    let targetStates : [TargetState]
    var currentState = ActivityState()
    var prevState = ActivityState()
    
    var success = true
    var feedback : [String]
    var durations : [Double]
    
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
        get { return max(0, targetStates[lastIndex].duration - durations[lastIndex]) }
    }
    
    init() {
        self.targetStates = []
        self.durations = []
        self.feedback = []
    }
    
    init(_ targetStates : [TargetState]) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        for (joint, angles) in targetStates[0].jointAngles {
            let x : Float? = angles.x != nil ? Float(0) : nil
            let y : Float? = angles.y != nil ? Float(0) : nil
            let z : Float? = angles.z != nil ? Float(0) : nil
            // TODO: addAnchor can set the initial angles
            self.currentState.jointAngles[joint] = EulerAngles(x: x, y: y, z: z)
            self.currentState.jointVelocities[joint] = EulerAngles(x: x, y: y, z: z)
        }
        self.durations = []
        for _ in 0..<targetStates.count {
            self.durations.append(0)
        }
        self.feedback = []
    }
    
    func restart() {
        started = false
        index = -1
    }
    
    func reset() {
        index = 0
        lastIndex = 0
        targetIndex = 0
        for i in 0..<durations.count {
            durations[i] = 0
        }
        feedback = []
        lastFeedback = TimeInterval()
        repCount += 1
    }
    
    func completeRep() {
        if success {
            speaker.speak(statement: speaker.rewards.randomElement()!)
            repCount += 1
        } else {
            if feedback.count > 0 {
                // The state changed to -1 but returned to the current state immediately afterwards
                speaker.speak(statement: "Okay, but a bit wobbly.")
            } else {
                speaker.speak(statement: "Not quite. Next time try to")
                for statement in feedback {
                    speaker.speak(statement: statement)
                }
                feedback = []
            }
        }
        success = true
    }
    
    func isTurningPoint() -> (Bool, [String]) {
        var failed = [String]()
        for (joint, velocities) in currentState.jointVelocities {
            if let vcur = velocities.x, let vprev = prevState.jointVelocities[joint]?.x,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                failed.append(joint + "_x was \(abs(vcur))")
            }
            if let vcur = velocities.y, let vprev = prevState.jointVelocities[joint]?.y,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                failed.append(joint + "_y was \(abs(vcur))")
            }
            if let vcur = velocities.z, let vprev = prevState.jointVelocities[joint]?.z,
                abs(vcur) > turningPointTolerance && vprev.sign == vcur.sign {
                failed.append(joint + "_z was \(abs(vcur))")
            }
        }
        return (failed.count == 0, failed)
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) {
        updateState(bodyAnchor, 0.0)
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor, _ delta : Double) {
        prevState = currentState
        let newAngles = bodyAnchor.getBodyJointAngles(Array(currentState.jointAngles.keys))
        currentState.update(newAngles, dema, 1.0)
        
        // If we haven't started yet, check if we have reached the start state
        if !started {
            if currentState.reaches(targetStates[0]) {
                started = true
                index = 0
            }
            return
        }
        
        // If the index hasn't changed then ignore
        if index != -1 && currentState.reaches(targetStates[index]) {
            durations[index] += delta
            return
        }
        
        // If we returned to the same state as before, resume
        if index == -1 && currentState.reaches(targetStates[lastIndex]) {
            index = lastIndex
            return
        }
        
        // Only check state change if we are at a turning point
        let res = isTurningPoint()
        if res.0 {
            if !stillTurning {
//                    print("start turning")
                startedTurning = Date().timeIntervalSince1970
                stillTurning = true
            }
        } else {
            if stillTurning {
//                    print("stopped turning")
//                    print(res.1)
                stillTurning = false
                index = -1
            }
            return
        }
        
        // If we have reached the target, update state accordingly
        if currentState.reaches(targetStates[targetIndex]) {
            index = targetIndex
            durations[index] = 0 // or delta

            let expectedDuration = targetStates[lastIndex].duration
            if durations[lastIndex] < expectedDuration {
                success = false
                feedback.append("Stay in \(targetStates[lastIndex].name) state longer")
            }
            
            lastIndex = index
            targetIndex = (targetIndex + 1) % targetStates.count
            
            if index == 0 {
                completeRep()
            }
            print("Successful change to \(targetStates[index].name)")
            return
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            if currentState.reaches(targetStates[(targetIndex + i) % targetStates.count]) {
                // Update index variable
                index = (targetIndex + i) % targetStates.count
                
                // If we did not arrive back at the last state we reached, add feedback for the missed states
                if index != lastIndex {
                    durations[index] = delta

                    var missed = "Missed: \(targetStates[targetIndex].name)"
                    for j in 1..<i {
                        missed += " and " + targetStates[(targetIndex + j) % targetStates.count].name
                    }
                    feedback.append(missed)
                    
                    let expectedDuration = targetStates[lastIndex].duration
                    if durations[lastIndex] < expectedDuration {
                        feedback.append("You should stay in the \(targetStates[lastIndex].name) state longer.")
                    }
                } else {
                    durations[index] += delta
                }
                
                lastIndex = index
                targetIndex = (index + 1) % targetStates.count

                // The rep was not completed fully since we must have skipped a state
                success = false
                
                if index == 0 {
                    completeRep()
                }
                return
            }
        }
        
        let curTime = Date().timeIntervalSince1970
        if stillTurning && curTime - startedTurning > 1 && curTime - lastFeedback > 3 {
            lastFeedback = Date().timeIntervalSince1970
            let currentTarget = targetStates[targetIndex]
            let difference = currentTarget.jointAngles.difference(currentState.jointAngles, currentTarget.tolerances)
            for (joint, angles) in difference {
                if let dx = angles.x {
                    if dx > 0 {
                        speaker.speak(statement: "Increase x by \(abs(Int(round(dx)))) for joint: \(joint)")
                    } else {
                        speaker.speak(statement: "Decrease x by \(abs(Int(round(dx)))) for joint: \(joint)")
                    }
                }
                
                if let dy = angles.y {
                    if dy > 0 {
                        speaker.speak(statement: "Increase y by \(abs(Int(round(dy)))) for joint: \(joint)")
                    } else {
                        speaker.speak(statement: "Decrease y by \(abs(Int(round(dy)))) for joint: \(joint)")
                    }
                }
                
                if let dz = angles.z {
                    if dz > 0 {
                        speaker.speak(statement: "Increase z by \(abs(Int(round(dz)))) for joint: \(joint)")
                    } else {
                        speaker.speak(statement: "Decrease z by \(abs(Int(round(dz)))) for joint: \(joint)")
                    }
                }
            }
        }
        
        index = -1
        return
    }
}
