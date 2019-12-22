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
    
    public var description : String {
        var str = ""
        str = "State {\n"
        for joint in jointAngles.keys {
            str += joint + ": " + jointAngles[joint]!.description + "\n"
        }
        return str + "}\n"
    }
    
    init() {
        self.joints = []
        self.jointAngles = JointAngles()
        self.jointVelocities = JointAngles()
    }
    
    init(joints : [String]) {
        self.joints = joints
        self.jointAngles = JointAngles()
        self.jointVelocities = JointAngles()
        for joint in joints {
            jointAngles[joint] = EulerAngles()
            jointVelocities[joint] = EulerAngles()
        }
    }
    
    init(jointAngles : JointAngles) {
        self.joints = Array(jointAngles.keys)
        self.jointAngles = jointAngles
        self.jointVelocities = JointAngles()
        for (joint, angles) in jointAngles {
            let x : Float? = angles.x != nil ? Float(0) : nil
            let y : Float? = angles.y != nil ? Float(0) : nil
            let z : Float? = angles.z != nil ? Float(0) : nil
            self.jointVelocities[joint] = EulerAngles(x: x, y: y, z: z)
        }
    }
    
    init(copyOf: ActivityState) {
        self.joints = copyOf.joints
        self.jointAngles = copyOf.jointAngles
        self.jointVelocities = copyOf.jointVelocities
    }
    
    init(_ jointAngles : JointAngles, _ jointVelocities : JointAngles) {
        self.joints = Array(jointAngles.keys)
        self.jointAngles = jointAngles
        self.jointVelocities = JointAngles()
        for (joint, _) in jointAngles {
            self.jointVelocities[joint] = jointVelocities[joint]
        }
    }
    
    static func == (lhs: ActivityState, rhs: ActivityState) -> Bool {
        return lhs.jointAngles == rhs.jointAngles
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(jointAngles)
    }
    
    func reaches(_ target : TargetState) -> Bool {
        return target.reachedBy(self)
    }
        
    func update(_ newAngles : JointAngles, _ augmentation : (Float, Float) -> Float, _ delta : Float) {
        // TODO: Try apply augmentation twice to velocity and three/four times to acceleration
        for (joint, angles) in jointAngles {
            let velocities = jointVelocities[joint]!
            let newJointAngles = newAngles[joint]!
            
            var newX : Float? = nil, newY : Float? = nil, newZ : Float? = nil
            var vX : Float? = nil, vY : Float? = nil, vZ : Float? = nil
                        
            if let cur = angles.x {
                let curV = velocities.x!
                let newAngle = newJointAngles.x!
                newX = augmentation(newAngle, cur)
                vX = augmentation((newX! - cur) / delta, curV)
            }
            
            if let cur = angles.y {
                let curV = velocities.y!
                let newAngle = newJointAngles.y!
                newY = augmentation(newAngle, cur)
                vY = augmentation((newY! - cur) / delta, curV)
            }
            
            if let cur = angles.z {
                let curV = velocities.z!
                let newAngle = newJointAngles.z!
                newZ = augmentation(newAngle, cur)
                vZ = augmentation((newZ! - cur) / delta, curV)
            }
            
            jointAngles[joint] = EulerAngles(x: newX, y: newY, z: newZ)
            jointVelocities[joint] = EulerAngles(x: vX, y: vY, z: vZ)
            
//                if  {
//                    newX = augmentation(cur, prev)
//                    vX = augmentation((newX! - prev) / delta, prevV)
//                } else {
//                    newX = prev
//                    vX = 0
//                }
//            }
//
//            if let prev = prevAngles.y {
//                if let cur = angles.y, let prevV = prevVelocities.y {
//                    newY = augmentation(cur, prev)
//                    vY = augmentation((newY! - prev) / delta, prevV)
//                } else {
//                    newY = prev
//                    vY = 0
//                }
//            }
//
//            if let prev = prevAngles.z {
//                if let cur = angles.z, let prevV = prevVelocities.z {
//                    newZ = augmentation(cur, prev)
//                    vZ = augmentation((newZ! - prev) / delta, prevV)
//                } else {
//                    newZ = prev
//                    vZ = 0
//                }
//            }
        }
    }
}
