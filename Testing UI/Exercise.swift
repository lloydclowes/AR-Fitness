//
//  Exercise.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct Exercise { // Hashable, Codable {
    
    var name: String
    var intensity: Intensity = .none
    var muscleGroup: MuscleGroup = .none
    
    private init(name: String) {
        self.name = name
    }
    
    init(name: String, intensity: Intensity) {
        self.init(name: name)
        self.intensity = intensity
    }
    
    init(name: String, muscleGroup: MuscleGroup) {
        self.init(name: name)
        self.muscleGroup = muscleGroup
    }
    
    enum Intensity {
        case high
        case low
        case none
    }

    enum MuscleGroup {
        case core
        case legs
        case arms
        case wholeBody
        case none
    }
    
}


