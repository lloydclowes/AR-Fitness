//
//  JointHistory.swift
//  AR-Fitness
//
//  Created by Brandon Forbes on 27/11/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import Foundation

typealias StateHistory = Dictionary<String, JointHistory>

struct JointHistory {
    var xs = [Float?]()
    var ys = [Float?]()
    var zs = [Float?]()
        
    func count() -> Int {
        return self.xs.count
    }
    
    mutating func append(jointAngles: EulerAngles) {
        self.xs.append(jointAngles.x)
        self.ys.append(jointAngles.y)
        self.zs.append(jointAngles.z)
    }
    
    mutating func remove(at: Int) {
        self.xs.remove(at: at)
        self.ys.remove(at: at)
        self.zs.remove(at: at)
    }
}
