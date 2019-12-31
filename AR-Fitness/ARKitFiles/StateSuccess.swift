//
//  StateSuccess.swift
//  AR-Fitness
//
//  Created by Brandon Forbes on 31/12/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import Foundation

struct StateSuccess {
    var duration : Double = 0.0
//    var success : Bool = true
    var jointFailures : Set<String> = []
    
    init(joints : [String]) {
        for joint in joints {
            jointFailures.insert(joint)
        }
    }
}
