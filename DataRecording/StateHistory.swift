//
//  StateHistory.swift
//  AR-Fitness
//
//  Created by Brandon Forbes on 20/11/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import Foundation

struct TimedState : Codable {
    let timestamp : Date
    let augmentedState : ActivityState
    let naturalState : ActivityState
    
    init(_ timestamp : Date, _ augmentedState : ActivityState, _ naturalState : ActivityState) {
        self.timestamp = timestamp
        self.augmentedState = augmentedState
        self.naturalState = naturalState
    }
}

struct StateHistory : Codable {
    var history : [TimedState]
}
