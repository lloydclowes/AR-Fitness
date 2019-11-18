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
        if index != -1 && index < targetStates.count && targetStates[index].reachedBy(bodyAnchor) {
            return index
        }
        
        for i in 0..<targetStates.count {
            if targetStates[(targetIndex + i) % targetStates.count].reachedBy(bodyAnchor) {
                index = targetIndex + i
                lastIndex = index
                targetIndex = (lastIndex + 1) % targetStates.count
                return i
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
