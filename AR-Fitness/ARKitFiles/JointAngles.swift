import Foundation

struct JointAngles : Hashable, Codable, Sequence {
    var jointAngles : Dictionary<String, EulerAngles> = [:]
    
    public var keys : Dictionary<String, EulerAngles>.Keys {
        get { return jointAngles.keys }
    }
    
    init() {}
    
    init(joints: [String]) {
        for joint in joints {
            jointAngles[joint] = EulerAngles()
        }
    }
    
    init(jointAngles: Dictionary<String, EulerAngles>) {
        self.jointAngles = jointAngles
    }
    
    subscript(index: String) -> EulerAngles? {
        get {
            return jointAngles[index]
        }
        set(newValue) {
            jointAngles[index] = newValue
        }
    }
    
    static func == (lhs: JointAngles, rhs: JointAngles) -> Bool {
        return lhs.jointAngles == rhs.jointAngles
    }
    
    func makeIterator() -> Dictionary<String, EulerAngles>.Iterator {
        return jointAngles.makeIterator()
    }
    
    func difference(_ other : JointAngles, _ tolerances : JointAngles) -> JointAngles {
        var diff = JointAngles()
        for (joint, angles) in jointAngles {
            let otherAngles = other.jointAngles[joint] ?? EulerAngles()
            let jointDiff = angles.difference(otherAngles, tolerances[joint]!)
            if jointDiff != EulerAngles() {
                diff[joint] = jointDiff
            }
        }

        return diff
    }
}
