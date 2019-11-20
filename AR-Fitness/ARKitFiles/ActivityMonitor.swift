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
    
    let targetStates : [TargetState]
    var currentState = ActivityState()
    
    let improvableStates : [TargetState]
    // let holdingDurations : [Double]
    
    var index = 0
    var improvableIndex = 0
    let speaker = SpeechSynthesizer()
    
    var lastIndex = 0
    var targetIndex = 0
    var lastSuccess = false
    var success = true
    
    init() {
        self.targetStates = []
        self.improvableStates = []
    }
    
    init(_ targetStates : [TargetState]) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.improvableStates = []
    }
    
    init(_ targetStates : [TargetState], improvableStates: [TargetState]) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.improvableStates = improvableStates
    }
    
    func retain(_ cur : Float, _ prev : Float) -> Float {
        return cur
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) -> Int {
        
        let newState = bodyAnchor.getBodyState(Array(currentState.jointAngles.keys))
        currentState.augment(newState, dema)
//        currentState.augment(newState, retain)  // Use retain to ignore the previous value completely
        
        // If the index hasn't changed then ignore
        if index != -1 && index < targetStates.count && currentState.reaches(targetStates[index]) {
            return index
        }
        
        // If the target has been reached, move to the next state
        if currentState.reaches(targetStates[targetIndex]) {
            index = targetIndex
            lastIndex = index
            targetIndex = (targetIndex + 1) % targetStates.count
            
            // If we got back to 0, reset success and assign the lastSuccess param ready for next rep
            if index == 0 {
                lastSuccess = true
                success = true
            }
            return index
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            if currentState.reaches(targetStates[(targetIndex + i) % targetStates.count]) {
                // Update index variables
                index = (targetIndex + i) % targetStates.count
                lastIndex = index
                targetIndex = (index + 1) % targetStates.count
                
                // The rep was not completed fully since we must have skipped a state
                success = false
                
                // If we got back to 0, reset success and assign the lastSuccess param ready for next rep
                if index == 0 {
                    lastSuccess = false
                    success = true
                }
                
                return index
            }
        }
        
        index = -1
        return -1
    }
    
    func getStateName() -> String {
        return targetStates[targetIndex].name
    }
    
    func getImprovementName() -> String {
        return improvableStates[improvableIndex].name
    }
    
    func checkForStateAdvance(_ bodyAnchor : ARBodyAnchor) -> Bool {
        let newState = bodyAnchor.getBodyState(Array(currentState.jointAngles.keys))
        currentState.augment(newState, dema)
//        currentState.augment(newState, retain)  // Use retain to ignore the previous value completely
        
        if currentState.reaches(targetStates[index]) {
            index = (index + 1) % targetStates.count
            return true
        }
        return false
    }
}
