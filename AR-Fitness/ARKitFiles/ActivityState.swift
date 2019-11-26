//
//  ActivityState.swift
//  AR-Sports
//
//  Created by Brandon Forbes on 21/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import Foundation
import ARKit

class ActivityState: Hashable, Codable {
    var jointAngles : JointAngles
    
    init() {
        self.jointAngles = JointAngles()
    }
    
    init(_ jointAngles : JointAngles) {
        self.jointAngles = jointAngles
    }
    
    static func == (lhs: ActivityState, rhs: ActivityState) -> Bool {
        return lhs.jointAngles == rhs.jointAngles
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(jointAngles)
    }
    
    func valueNotReached(current curr: Float, target targ: Float, tolerance tol: Float) -> Bool {
        return tol <= 0.0 && curr < targ + tol || tol >= 0.0 && curr > targ + tol
    }
    
    func reaches(_ target : TargetState) -> Bool {
        return target.reachedBy(self)
    }
    
    func augment(_ other : ActivityState, _ augmentation : (Float, Float) -> Float) -> ActivityState {
        var newJointAngles = JointAngles()
        for (joint, angles) in other.jointAngles {
            // The following behaviour could be a default instead of skipping
            let prevAngles = jointAngles[joint]!
            
            var newX : Float? = nil
            if let cur = angles.x {
//                let cur = currentAngles.x!
                if let prev = prevAngles.x {
                    newX = augmentation(cur, prev)
                } else {
                    newX = cur
                }
            }
            
            var newY : Float? = nil
            if let cur = angles.y {
//                let cur = currentAngles.y!
                if let prev = prevAngles.y {
                    newY = augmentation(cur, prev)
                } else {
                    newY = cur
                }
            }
            
            var newZ : Float? = nil
            if let cur = angles.z {
//                let cur = currentAngles.z!
                if let prev = prevAngles.z {
                    newZ = augmentation(cur, prev)
                } else {
                    newZ = cur
                }
            }
            
            newJointAngles[joint] = EulerAngles(x: newX, y: newY, z: newZ)
        }
        
        return ActivityState(newJointAngles)
    }
}
