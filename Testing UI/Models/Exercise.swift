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
    var className: String
    var duration: String
    
}

enum Intensity: String, CaseIterable, Codable, Hashable {
    case high = "High"
    case low = "Low"
}

enum MuscleGroup: String, CaseIterable, Codable, Hashable {
    
    case legs = "Legs"
    case arms = "Arms"
    case wholeBody = "Whole body"
    case core = "Core"
    
    public static func getIconName(_ muscleGroup: MuscleGroup) -> String {
        switch muscleGroup {
            case .legs: return "leg-icon"
            case .arms: return "arm-icon"
            case .wholeBody: return "whole-body-icon"
            case .core: return "core-icon"
        }
    }
    
    public static func getIconColor(_ muscleGroup: MuscleGroup) -> UIColor {
        switch muscleGroup {
            case .legs: return .red
            case .arms: return UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1.0)
            case .wholeBody: return .purple
            case .core: return .orange
        }
    }
    
    public static var allCases: [MuscleGroup] {
        return [.legs, .arms, .wholeBody, .core]
    }
    
}
