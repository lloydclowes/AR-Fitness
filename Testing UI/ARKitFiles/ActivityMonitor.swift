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
    
    let targetStates : [ActivityState]
    let improvableStates : [ActivityState]
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
    
    init(_ targetStates : [ActivityState]) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.improvableStates = []
    }
    
    init(_ targetStates : [ActivityState], improvableStates: [ActivityState]) {
        self.targetStates = targetStates
        self.targetIndex = targetStates.count > 1 ? 1 : 0
        self.improvableStates = improvableStates
    }
    
    func updateState(_ bodyAnchor : ARBodyAnchor) -> Int {
        // If the index hasn't changed then ignore
        if index != -1 && index < targetStates.count && targetStates[index].reachedBy(bodyAnchor) {
            return index
        }
        
        // If the target has been reached, move to the next state
        if targetStates[targetIndex].reachedBy(bodyAnchor) {
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
            if targetStates[(targetIndex + i) % targetStates.count].reachedBy(bodyAnchor) {
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
        if targetStates[index].reachedBy(bodyAnchor) {
            index = (index + 1) % targetStates.count
            return true
        }
        return false
    }
}
