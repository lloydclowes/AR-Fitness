//
//  JointUtilities.swift
//  AR-Fitness
//
//  Created by Group 8 on 31/12/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import Foundation

let mappings = [
    "left_upLeg_joint": "left thigh",
    "right_upLeg_joint": "right thigh",
    "left_leg_joint": "left leg",
    "right_leg_joint": "right leg",
    "left_arm_joint": "left arm",
    "right_arm_joint": "right arm",
    "left_forearm_joint": "left forearm",
    "right_forearm_joint": "right forearm"
]

func jointToName(_ joint: String) -> String {
    if (mappings[joint] != nil) {
        return mappings[joint]!
    }
    return joint
}
