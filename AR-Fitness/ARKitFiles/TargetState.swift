import Foundation

class TargetState : ActivityState {
    let name : String
    let duration : Double
    let feedback : Dictionary<String, JointFeedback>
    
    enum TargetStateKeys: String, CodingKey {
        case name = "name"
        case jointAngles = "jointAngles"
        case duration = "duration"
        case feedback = "feedback"
    }
    
    init(_ name : String) {
        self.name = name
        self.duration = 0
        self.feedback = [:]
        super.init(jointAngles: JointAngles())
    }
    
    init(_ name : String, _ jointAngles : JointAngles, _ duration : Double,
         _ feedback : Dictionary<String, JointFeedback>) {
        self.name = name
        self.duration = duration
        self.feedback = feedback
        super.init(jointAngles: jointAngles)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TargetStateKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let jointAngles = try container.decode(JointAngles.self, forKey: .jointAngles)
        let duration = try container.decode(Double.self, forKey: .duration)
        let feedback = try container.decode(Dictionary<String, JointFeedback>.self, forKey: .feedback)
        self.init(name, jointAngles, duration, feedback)
    }
    
    static func == (lhs: TargetState, rhs: TargetState) -> Bool {
        return lhs.name == rhs.name && lhs.jointAngles == rhs.jointAngles /* && lhs.tolerances == rhs.tolerances */
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(jointAngles)
    }
    
    func reachedBy(_ activityState: ActivityState) -> Bool {
        let d = jointAngles.difference(activityState.jointAngles)
        return d.count == 0
    }
}
