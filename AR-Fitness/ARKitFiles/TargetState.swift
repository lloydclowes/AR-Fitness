import Foundation

class TargetState : ActivityState {
    let name : String
    let tolerances : JointAngles
    let duration : Double
    let feedback : Dictionary<String, JointFeedback>
    
    enum TargetStateKeys: String, CodingKey {
        case name = "name"
        case jointAngles = "jointAngles"
        case tolerances = "tolerances"
        case duration = "duration"
        case feedback = "feedback"
    }
    
    init(_ name : String) {
        self.name = name
        self.tolerances = JointAngles()
        self.duration = 0
        self.feedback = [:]
        super.init(jointAngles: JointAngles())
    }
    
    init(_ name : String, _ jointAngles : JointAngles, _ tolerances : JointAngles, _ duration : Double,
         _ feedback : Dictionary<String, JointFeedback>) {
        self.name = name
        self.tolerances = tolerances
        self.duration = duration
        self.feedback = feedback
        super.init(jointAngles: jointAngles)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TargetStateKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let jointAngles = try container.decode(JointAngles.self, forKey: .jointAngles)
        let tolerances = try container.decode(JointAngles.self, forKey: .tolerances)
        let duration = try container.decode(Double.self, forKey: .duration)
        let feedback = try container.decode(Dictionary<String, JointFeedback>.self, forKey: .feedback)
        self.init(name, jointAngles, tolerances, duration, feedback)
    }
    
    static func == (lhs: TargetState, rhs: TargetState) -> Bool {
        return lhs.name == rhs.name && lhs.jointAngles == rhs.jointAngles && lhs.tolerances == rhs.tolerances
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(jointAngles)
        hasher.combine(tolerances)
    }
    
    func valueBelowTarget(current curr: Float, target targ: Float, tolerance tol: Float) -> Bool {
        return tol <= 0.0 && curr < targ + tol
    }
    
    func valueAboveTarget(current curr: Float, target targ: Float, tolerance tol: Float) -> Bool {
        return tol >= 0.0 && curr > targ + tol
    }
    
    func valueNotReached(current curr: Float, target targ: Float, tolerance tol: Float) -> Bool {
        return valueBelowTarget(current: curr, target: targ, tolerance: tol) || valueAboveTarget(current: curr, target: targ, tolerance: tol)
    }
    
    func reachedBy(_ activityState: ActivityState) -> Bool {
        for (joint, targetAngles) in jointAngles {
            guard let angles = activityState.jointAngles[joint] else { return false }
            
            let jointTols = tolerances[joint]!
            if let tol = jointTols.x, let targ = targetAngles.x {
                guard let curr = angles.x else { return false }
                if valueNotReached(current: curr, target: targ, tolerance: tol) {
                    return false
                }
            }
            
            if let tol = jointTols.y, let targ = targetAngles.y {
                guard let curr = angles.y else { return false }
                if valueNotReached(current: curr, target: targ, tolerance: tol) {
                    return false
                }
            }
            
            if let tol = jointTols.z, let targ = targetAngles.z {
                guard let curr = angles.z else { return false }
                if valueNotReached(current: curr, target: targ, tolerance: tol) {
                    return false
                }
            }
        }
        
        return true
    }
}
