//
//  ActivityState.swift
//  AR-Sports
//
//  Created by Brandon Forbes on 21/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import Foundation
import ARKit

struct ActivityState {
    let name : String
    let jointAngles : JointAngles
    let tolerances : JointAngles
        
    init(_ name : String, _ jointAngles : JointAngles, _ tolerances : JointAngles) {
        self.name = name
        self.jointAngles = jointAngles
        self.tolerances = tolerances
    }
    
    func valueNotReached(current curr: Float, target targ: Float, tolerance tol: Float) -> Bool {
        return tol <= 0.0 && curr < targ + tol || tol >= 0.0 && curr > targ + tol
    }
    
    // TODO: invert and place into body anchor extension
    func reachedBy(_ bodyAnchor: ARBodyAnchor) -> Bool {
        for (joint, targetAngles) in jointAngles {
            let angles = bodyAnchor.getLocalJointAngleXYZ(joint)
            guard let tolerances = tolerances[joint] else { return false }
            
            if let tol = tolerances.x, let targ = targetAngles.x {
                guard let curr = angles.x else { return false }
                if valueNotReached(current: curr, target: targ, tolerance: tol) {
                    return false
                }
            }
            
            if let tol = tolerances.y, let targ = targetAngles.y {
                guard let curr = angles.y else { return false }
                if valueNotReached(current: curr, target: targ, tolerance: tol) {
                    return false
                }
            }
            
            if let tol = tolerances.z, let targ = targetAngles.z {
                guard let curr = angles.z else { return false }
                if valueNotReached(current: curr, target: targ, tolerance: tol) {
                    return false
                }
            }
        }
        
        return true
    }
}
