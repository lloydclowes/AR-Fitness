//
//  JointFeedback.swift
//  AR-Fitness
//
//  Created by Brandon Forbes on 03/01/2020.
//  Copyright © 2020 SE Project Group 8. All rights reserved.
//

import Foundation

struct Feedback : Hashable, Codable {
    let decrease : String
    let increase : String
}

struct JointFeedback : Hashable, Codable {
    let xFeedback : Feedback?
    let yFeedback : Feedback?
    let zFeedback : Feedback?
}

