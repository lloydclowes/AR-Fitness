//
//  Exercise.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct Exercise: Hashable, Codable, Identifiable {
    
    var id: Int
    var name: String
    var intensity: Intensity
    var muscleGroup: MuscleGroup
    var equipment: [String]
    
}

enum Intensity: String, CaseIterable, Codable, Hashable {
   case high = "High"
   case low = "Low"
}

enum MuscleGroup: String, CaseIterable, Codable, Hashable {
   case core = "Core"
   case legs = "Legs"
   case arms = "Arms"
   case wholeBody = "Whole body"
}
