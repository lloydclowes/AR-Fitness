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
    
    let targetStates : [TargetState]
    var currentState = ActivityState()
    
    var success = true
    var feedback : [String]
    var durations : [Double]
    
    var index = 0
    var improvableIndex = 0
    var lastIndex = 0
    var targetIndex = 0
    var repCount = 0
    
    let speaker = SpeechSynthesizer.globalSpeaker
    
    var lastFeedback : TimeInterval
    
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
        self.useTurningPoints = false
        self.durations = []
        self.feedback = []
        self.lastFeedback = Date().timeIntervalSince1970
    }
    
    init(_ targetStates : [TargetState], useTurningPoints : Bool = false) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.useTurningPoints = useTurningPoints
        if targetStates.count > 0 {
            for (joint, angles) in targetStates[targetIndex].jointAngles {
                let x : Float? = angles.x != nil ? Float(0) : nil
                let y : Float? = angles.y != nil ? Float(0) : nil
                let z : Float? = angles.z != nil ? Float(0) : nil
                // TODO: addAnchor can set the initial angles
                self.currentState.jointAngles[joint] = EulerAngles(x: x, y: y, z: z)
            }
        }
        self.durations = []
        for _ in 0..<targetStates.count {
            self.durations.append(0)
        }
        self.feedback = []
        self.lastFeedback = Date().timeIntervalSince1970
    }
    
    func reset() {
        index = 0
        improvableIndex = 0
        lastIndex = 0
        targetIndex = 0
        for i in 0..<durations.count {
            durations[i] = 0
        }
        feedback = []
        lastFeedback = Date().timeIntervalSince1970
        repCount += 1
    }
    
    func completeRep() {
        if success {
            speaker.speak(statement: speaker.rewards.randomElement()!)
            repCount += 1
        } else {
            if feedback.count == 0 {
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
    
    func updateState(_ bodyAnchor : ARBodyAnchor) {
        updateState(bodyAnchor, 0.0)
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor, _ delta : Double) {
        let newAngles = bodyAnchor.getBodyJointAngles(Array(currentState.jointAngles.keys))
        currentState.update(newAngles, dema, 1.0)
        
        // If the index hasn't changed then ignore
        if index != -1 && currentState.reaches(targetStates[index]) {
            durations[index] += delta
            return
        }
        
        // If we are using turning points, only check if we are at a turning point
        if useTurningPoints && !currentState.isTurningPoint() {
            index = -1
            return
        }
        
        // If we returned to the same state as before, resume
        if index == -1 && currentState.reaches(targetStates[lastIndex]) {
            index = lastIndex
//            durations[index] += delta
            success = false
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
            print("Successful state change")
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
        
        if Date().timeIntervalSince1970 - lastFeedback > 3 {
            lastFeedback = Date().timeIntervalSince1970
            let currentTarget = targetStates[targetIndex]
            let difference = currentTarget.jointAngles.difference(currentState.jointAngles, currentTarget.tolerances)
            for (joint, angles) in difference {
                if let dx = angles.x {
                    if dx > 0 {
                        speaker.speak(statement: "Increase x for joint: \(joint)")
                    } else {
                        speaker.speak(statement: "Decrease x for joint: \(joint)")
                    }
                }
                
                if let dy = angles.y {
                    if dy > 0 {
                        speaker.speak(statement: "Increase y for joint: \(joint)")
                    } else {
                        speaker.speak(statement: "Decrease y for joint: \(joint)")
                    }
                }
                
                if let dz = angles.z {
                    if dz > 0 {
                        speaker.speak(statement: "Increase z for joint: \(joint)")
                    } else {
                        speaker.speak(statement: "Decrease z for joint: \(joint)")
                    }
                }
            }
        }
        
        index = -1
        return
    }
}
