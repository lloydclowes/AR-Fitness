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
    // let holdingDurations : [Double]
    
    var index = 0
    
    init() {
        self.targetStates = []
    }
    
    init(_ targetStates : [ActivityState]) {
        self.targetStates = targetStates
    }
    
    func getStateName() -> String {
        return targetStates[index].name
    }
    
    func checkForStateAdvance(_ bodyAnchor : ARBodyAnchor) -> Bool {
        if targetStates[index].reachedBy(bodyAnchor) {
            index = (index + 1) % targetStates.count
            return true
        }
        return false
    }
    
}
