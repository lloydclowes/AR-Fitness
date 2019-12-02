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
    let coachingInfo : CoachModeDetail?
    
    let targetStates : [TargetState]
    var currentState = ActivityState()
    
    var index = 0
    var improvableIndex = 0
    let speaker = SpeechSynthesizer.globalSpeaker
    
    var lastIndex = 0
    var targetIndex = 0
    var feedback = [String]()
    var success = true
    var timer = Timer()
    var counter = Float(0)
    
    var repCount = 0
    
    init() {
        self.targetStates = []
        self.useTurningPoints = false
        self.inCoachingMode = false
        self.coachingInfo = nil
    }
    
    init(_ targetStates : [TargetState], useTurningPoints : Bool = false, coachingMode : Bool = false, coachingInfo : CoachModeDetail? = nil) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.useTurningPoints = useTurningPoints
        self.inCoachingMode = coachingMode
        self.coachingInfo = coachingInfo
        if targetStates.count > 0 {
            for (joint, angles) in targetStates[targetIndex].jointAngles {
                let x : Float? = angles.x != nil ? Float(0) : nil
                let y : Float? = angles.y != nil ? Float(0) : nil
                let z : Float? = angles.z != nil ? Float(0) : nil
                // TODO: addAnchor can set the initial angles
                self.currentState.jointAngles[joint] = EulerAngles(x: x, y: y, z: z)
            }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer, forMode: .common)
    }
    
    func completeRep() {
        if success {
            speaker.speak(statement: "GOOD WORK!") // Isn't it too much to repeat it for every rep?
            repCount += 1
        } else {
            if feedback.count == 0 {
                // The state changed to -1 but returned to the current state immediately afterwards
                speaker.speak(statement: "Okay, but a bit wobbly.")
            } else {
                speaker.speak(statement: "NOT QUITE: \(feedback)")
            }
            feedback = []
        }
        success = true
    }
    
    func coachingMode() {
        // Add instructions to exerciseData to be said outloud when reaching a state, so for
        // the target state.
        if currentState.reaches(targetStates[targetIndex]) {
        let expectedTransitionDuration = coachingInfo!.transitionDuration
        if Int(counter) < expectedTransitionDuration {
                speaker.speak(statement: speaker.speedFocusedStatements.randomElement()!)
        }
        counter = 0
        
        index = targetIndex
        lastIndex = index
        targetIndex = (targetIndex + 1) % targetStates.count
        
        if index == 0 {
            //completeRep()
        }
            speaker.speak(statement: " \(coachingInfo!.stateInstructions[targetIndex])")
        }
//        } else if !currentState.isTurningPoint() {
//            speaker.speak(statement: "You need to move to state \(targetStates[targetIndex].name)")
//        }
        return
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) {
        let newAngles = bodyAnchor.getBodyJointAngles(Array(currentState.jointAngles.keys))
        currentState.update(newAngles, dema, 1.0)
        
        // If the index hasn't changed then ignore
        if index != -1 && index < targetStates.count && currentState.reaches(targetStates[index]) {
            return
        }
        
        // If we are using turning points, only check if we are at a turning point
        if useTurningPoints && !currentState.isTurningPoint() {
            index = -1
            return
        }
        
        if (self.inCoachingMode) {
            self.coachingMode()
            return
        }
        
        // If we have reached the target, update state accordingly
        if currentState.reaches(targetStates[targetIndex]) {
//            let expectedDuration = targetStates[(targetIndex + 1) % targetStates.count].duration
//            if counter < expectedDuration && lastIndex != targetIndex {
//                speaker.speak(statement: "stay \((targetStates[(targetIndex + 1) % targetStates.count]).name) longer")
//            }
            let expectedDuration = targetStates[lastIndex].duration
            if counter < expectedDuration {
                speaker.speak(statement: "Stay in \(targetStates[lastIndex].name) state longer")
            }
            counter = 0
            
            index = targetIndex
            lastIndex = index
            targetIndex = (targetIndex + 1) % targetStates.count
            
            if index == 0 {
                completeRep()
            }
            speaker.speak(statement: "Keep it up... done: \(targetStates[index].name) target: \(targetStates[targetIndex].name)")
            return
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            if currentState.reaches(targetStates[(targetIndex + i) % targetStates.count]) {
                // Update index variables
                index = (targetIndex + i) % targetStates.count
                
                // If we did not arrive back at the last state we reached, add feedback for the missed states
                if index != lastIndex {
                    var missed = "Missed: \(targetStates[targetIndex].name)"
                    for j in 1..<i {
                        missed += " and " + targetStates[(targetIndex + j) % targetStates.count].name
                    }
                    feedback.append(missed)
                    
                    // TODO: I think we need the below here as well
                    let expectedDuration = targetStates[lastIndex].duration
                    if counter < expectedDuration {
                        speaker.speak(statement: "Stay in \(targetStates[lastIndex].name) state longer")
                    }
                    counter = 0
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
        
        // TODO: Live feedback goes here -> turning point and not in any state => "Get lower!" or something
        
        
        
        index = -1
        return
    }
    
    func getStateName() -> String {
        return targetStates[targetIndex].name
    }
    
    @objc func timerAction() {
        counter += 1
    }
}
