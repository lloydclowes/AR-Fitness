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
            jointAngles[joint] = EulerAngles(x: nil as EulerAngle?)
            jointVelocities[joint] = EulerAngles(x: nil as EulerAngle?)
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
        
    func getMaxSpeed() -> Float {
        var maxSpeed = Float(0)
        for (_, v) in jointVelocities {
            maxSpeed = Float.maximum(maxSpeed, v.magnitude())
        }
        return maxSpeed
    }
    
    func update(_ newAngles : JointAngles, _ augmentation : (Float, Float) -> Float, _ delta : Float) {
        // TODO: Try apply augmentation twice to velocity and three/four times to acceleration
        for (joint, angles) in jointAngles {
            let velocities = jointVelocities[joint]!
            let newJointAngles = newAngles[joint]!
            
            var newX : Float? = nil, newY : Float? = nil, newZ : Float? = nil
            var vX : Float? = nil, vY : Float? = nil, vZ : Float? = nil
                        
            if let cur = angles.x?.val {
                let curV = velocities.x!.val
                let newAngle = newJointAngles.x!.val
                newX = augmentation(newAngle, cur)
                vX = augmentation((newX! - cur) / delta, curV)
            }
            
            if let cur = angles.y?.val {
                let curV = velocities.y!.val
                let newAngle = newJointAngles.y!.val
                newY = augmentation(newAngle, cur)
                vY = augmentation((newY! - cur) / delta, curV)
            }
            
            if let cur = angles.z?.val {
                let curV = velocities.z!.val
                let newAngle = newJointAngles.z!.val
                newZ = augmentation(newAngle, cur)
                vZ = augmentation((newZ! - cur) / delta, curV)
            }
            
            jointAngles[joint] = EulerAngles(x: newX, y: newY, z: newZ)
            jointVelocities[joint] = EulerAngles(x: vX, y: vY, z: vZ)
        }
    }
}
