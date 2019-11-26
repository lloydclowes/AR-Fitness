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
    
//    var augmentedHistory : [ActivityState]
//    var naturalHistory : [ActivityState]
    
    var augmentedState = ActivityState()
    var naturalState = ActivityState()
    var prevTime = 0.0
    
    let improvableStates : [TargetState]
    // let holdingDurations : [Double]
    
    var index = 0
    var improvableIndex = 0
    let speaker = SpeechSynthesizer()
    
    var lastIndex = 0
    var targetIndex = 0
    var failedIndex = -1
    var lastSuccess = true
    var success = true
    
    init() {
        self.targetStates = []
        self.improvableStates = []
    }
    
    init(_ targetStates : [TargetState]) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        if targetStates.count > 0 {
            for key in targetStates[targetIndex].jointAngles.keys {
                self.augmentedState.jointAngles[key] = EulerAngles()
                self.naturalState.jointAngles[key] = EulerAngles()
            }
        }
        self.improvableStates = []
    }
    
    init(_ targetStates : [TargetState], improvableStates: [TargetState]) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        if targetStates.count > 0 {
            for key in targetStates[targetIndex].jointAngles.keys {
                self.augmentedState.jointAngles[key] = EulerAngles()
                self.naturalState.jointAngles[key] = EulerAngles()
            }
        }
        self.improvableStates = improvableStates
    }
    
    // Use replace as augmentation function to ignore the previous value completely
    func replace(_ cur : Float, _ prev : Float) -> Float {
        return cur
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) -> Int {
        let newAngles = bodyAnchor.getBodyJointAngles(Array(augmentedState.jointAngles.keys))
        
        let curTime = Date().timeIntervalSince1970
        let delta = Float(curTime - prevTime)
        prevTime = curTime
        
        // TODO: move the augmentation function to member variable passed in to init(...)
        augmentedState = augmentedState.update(newAngles, dema, delta)
        naturalState = naturalState.update(newAngles, replace, delta)
        
        // If the index hasn't changed then ignore
        if index != -1 && index < targetStates.count && augmentedState.reaches(targetStates[index]) {
            return index
        }
        
        // If the target has been reached, move to the next state
        if augmentedState.reaches(targetStates[targetIndex]) {
            index = targetIndex
            lastIndex = index
            targetIndex = (targetIndex + 1) % targetStates.count
            
            // If we got back to 0, reset success
            if index == 0 {
                lastSuccess = success
                success = true
            }
            return index
        }
        
        // Check any following states for matches
        for i in 1..<targetStates.count {
            // If we have reached a future state
            if augmentedState.reaches(targetStates[(targetIndex + i) % targetStates.count]) {
                // Update index variables
                index = (targetIndex + i) % targetStates.count
                lastIndex = index
                failedIndex = targetIndex
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
        let newAngles = bodyAnchor.getBodyJointAngles(Array(augmentedState.jointAngles.keys))
        
        let curTime = Date().timeIntervalSince1970
        let delta = Float(curTime - prevTime)
        prevTime = curTime
        
        augmentedState = augmentedState.update(newAngles, dema, delta)
        naturalState = naturalState.update(newAngles, replace, delta)  // Use replace to ignore the previous value completely
        
        if augmentedState.reaches(targetStates[index]) {
            index = (index + 1) % targetStates.count
            return true
        }
        return false
    }
}
