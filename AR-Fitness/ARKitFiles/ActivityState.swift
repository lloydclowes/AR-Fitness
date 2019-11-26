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
    
    func augment(_ newAngles : JointAngles, _ augmentation : (Float, Float) -> Float) -> JointAngles {
        var newJointAngles = JointAngles()
        for (joint, angles) in newAngles {
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
        return newJointAngles
    }
    
    func updateVelocities(_ newAngles : JointAngles, _ augmentation : (Float, Float) -> Float, _ delta : Float) -> JointAngles {
        var newJointVelocities = JointAngles()
        for (joint, angles) in newAngles {
            // The following behaviour could be a default instead of skipping
            let prevAngles = jointAngles[joint]!
            
            var newX : Float? = nil
            if let cur = angles.x {
//                let cur = currentAngles.x!
                if let prev = prevAngles.x {
                    newX = augmentation((cur - prev) / delta, prev)
                } else {
                    newX = cur
                }
            }
            
            var newY : Float? = nil
            if let cur = angles.y {
//                let cur = currentAngles.y!
                if let prev = prevAngles.y {
                    newY = augmentation((cur - prev) / delta, prev)
                } else {
                    newY = cur
                }
            }
            
            var newZ : Float? = nil
            if let cur = angles.z {
//                let cur = currentAngles.z!
                if let prev = prevAngles.z {
                    newZ = augmentation((cur - prev) / delta, prev)
                } else {
                    newZ = cur
                }
            }
            
            newJointVelocities[joint] = EulerAngles(x: newX, y: newY, z: newZ)
        }
        return newJointVelocities
    }
    
    func updateAccelerations(_ newVelocities : JointAngles, _ augmentation : (Float, Float) -> Float, _ delta : Float) -> JointAngles {
        var newJointAccelerations = JointAngles()
        for (joint, angles) in newVelocities {
            // The following behaviour could be a default instead of skipping
            if let prevVelocities = jointVelocities[joint] {
                var newX : Float? = nil
                if let cur = angles.x {
    //                let cur = currentAngles.x!
                    if let prev = prevVelocities.x {
                        newX = augmentation((cur - prev) / delta, prev)
                    } else {
                        newX = cur
                    }
                }
                
                var newY : Float? = nil
                if let cur = angles.y {
    //                let cur = currentAngles.y!
                    if let prev = prevVelocities.y {
                        newY = augmentation((cur - prev) / delta, prev)
                    } else {
                        newY = cur
                    }
                }
                
                var newZ : Float? = nil
                if let cur = angles.z {
    //                let cur = currentAngles.z!
                    if let prev = prevVelocities.z {
                        newZ = augmentation((cur - prev) / delta, prev)
                    } else {
                        newZ = cur
                    }
                }
                
                newJointAccelerations[joint] = EulerAngles(x: newX, y: newY, z: newZ)
            }
        }
        return newJointAccelerations
    }
    
    func update(_ newAngles : JointAngles, _ augmentation : (Float, Float) -> Float, _ delta : Float) -> ActivityState {
        let augmentedAngles = augment(newAngles, augmentation)
        let newJointVelocities = updateVelocities(augmentedAngles, augmentation, delta)
        let newJointAccelerations = updateAccelerations(newJointVelocities, augmentation, delta)
        return ActivityState(augmentedAngles, newJointVelocities, newJointAccelerations)
    }
}
