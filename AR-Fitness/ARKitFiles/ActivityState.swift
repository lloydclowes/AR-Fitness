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
    let joints : [String]
    var jointAngles : JointAngles
    var jointVelocities : JointAngles
    var jointAccelerations : JointAngles
    
    init() {
        self.joints = []
        self.jointAngles = JointAngles()
        self.jointVelocities = JointAngles()
        self.jointAccelerations = JointAngles()
    }
    
    init(joints : [String]) {
        self.joints = joints
        self.jointAngles = JointAngles()
        self.jointVelocities = JointAngles()
        self.jointAccelerations = JointAngles()
        for joint in joints {
            jointAngles[joint] = EulerAngles()
            jointVelocities[joint] = EulerAngles(x: 0, y: 0, z: 0)
            jointAccelerations[joint] = EulerAngles(x: 0, y: 0, z: 0)
        }
    }
    
    init(jointAngles : JointAngles) {
        self.joints = Array(jointAngles.keys)
        self.jointAngles = jointAngles
        self.jointVelocities = JointAngles()
        self.jointAccelerations = JointAngles()
        for (joint, _) in jointAngles {
            self.jointVelocities[joint] = EulerAngles(x: 0, y: 0, z: 0)
            self.jointAccelerations[joint] = EulerAngles(x: 0, y: 0, z: 0)
        }
    }
    
    init(copyOf: ActivityState) {
        self.joints = copyOf.joints
        self.jointAngles = copyOf.jointAngles
        self.jointVelocities = copyOf.jointVelocities
        self.jointAccelerations = copyOf.jointAccelerations
    }
    
    init(_ jointAngles : JointAngles, _ jointVelocities : JointAngles, _ jointAccelerations : JointAngles) {
        self.joints = Array(jointAngles.keys)
        self.jointAngles = jointAngles
        self.jointVelocities = JointAngles()
        self.jointAccelerations = JointAngles()
        for (joint, _) in jointAngles {
            self.jointVelocities[joint] = jointVelocities[joint]
            self.jointAccelerations[joint] = jointAccelerations[joint]
        }
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
    
    func update(_ newAngles : JointAngles, _ augmentation : (Float, Float) -> Float, _ delta : Float) {
        for (joint, angles) in newAngles {
            let prevAngles = jointAngles[joint] ?? EulerAngles()
            let prevVelocities = jointAngles[joint] ?? EulerAngles()
            
            var newX : Float? = nil, newY : Float? = nil, newZ : Float? = nil
            var vX : Float? = nil, vY : Float? = nil, vZ : Float? = nil
            var aX : Float? = nil, aY : Float? = nil, aZ : Float? = nil
            
            if let cur = angles.x {
                if let prev = prevAngles.x, let prevV = prevVelocities.x {
                    newX = augmentation(cur, prev)
                    vX = (newX! - prev) / delta
                    aX = (vX! - prevV) / delta
                } else {
                    newX = cur
                    vX = newX
                    aX = vX
                }
            }
            
            if let cur = angles.y {
                if let prev = prevAngles.y, let prevV = prevVelocities.y {
                    newY = augmentation(cur, prev)
                    vY = (newY! - prev) / delta
                    aY = (vY! - prevV) / delta
                } else {
                    newY = cur
                    vY = newY
                    aY = vY
                }
            }
            
            if let cur = angles.z {
                if let prev = prevAngles.z, let prevV = prevVelocities.z {
                    newZ = augmentation(cur, prev)
                    vZ = (newZ! - prev) / delta
                    aZ = (vZ! - prevV) / delta
                } else {
                    newZ = cur
                    vZ = newZ
                    aZ = vZ
                }
            }
            
            jointAngles[joint] = EulerAngles(x: newX, y: newY, z: newZ)
            jointVelocities[joint] = EulerAngles(x: vX, y: vY, z: vZ)
            jointAccelerations[joint] = EulerAngles(x: aX, y: aY, z: aZ)
        }
    }
}
