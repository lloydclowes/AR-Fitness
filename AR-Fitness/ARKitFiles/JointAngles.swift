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
    
    public var count : Int {
        get { return jointAngles.count }
    }
    
    func makeIterator() -> Dictionary<String, EulerAngles>.Iterator {
        return jointAngles.makeIterator()
    }
    
    func difference(_ other : JointAngles) -> JointAngles {
        var diff = JointAngles()
        for (joint, angles) in jointAngles {
            let jointDiff = angles.difference(other.jointAngles[joint]!)
            if jointDiff != EulerAngles() {
                diff[joint] = jointDiff
            }
        }
        return diff
    }
}
