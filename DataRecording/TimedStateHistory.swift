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
    
    init(_ timestamp : Date, _ augmentedState : ActivityState) {
        self.timestamp = timestamp
        self.augmentedState = augmentedState
    }
}

struct TimedStateHistory : Codable {
    var history : [TimedState]
}
