//
//  TargetState.swift
//  AR-Fitness
//
//  Created by Brandon Forbes on 20/11/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import Foundation

class TargetState : ActivityState {
    let name : String
    let tolerances : JointAngles
    let duration : Float
        
    enum MyStructKeys: String, CodingKey {
      case name = "name"
      case jointAngles = "jointAngles"
      case tolerances = "tolerances"
    }
    
    init(_ name : String) {
        self.name = name
        self.tolerances = JointAngles()
        self.duration = Float(0)
        super.init(jointAngles: JointAngles())
    }
    
    init(_ name : String, _ jointAngles : JointAngles, _ tolerances : JointAngles, _ duration : Float) {
        self.name = name
        self.tolerances = tolerances
        self.duration = duration
        super.init(jointAngles: jointAngles)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyStructKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let jointAngles = try container.decode(JointAngles.self, forKey: .jointAngles)
        let tolerances = try container.decode(JointAngles.self, forKey: .tolerances)
        self.init(name, jointAngles, tolerances, 0.0)
    }
    
    static func == (lhs: TargetState, rhs: TargetState) -> Bool {
        return lhs.name == rhs.name && lhs.jointAngles == rhs.jointAngles && lhs.tolerances == rhs.tolerances
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(jointAngles)
        hasher.combine(tolerances)
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
