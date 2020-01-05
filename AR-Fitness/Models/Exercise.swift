import SwiftUI

struct Exercise: Hashable, Codable, Identifiable {
    var id : Int
    var name : String
    var intensity : Intensity
    var muscleGroup : MuscleGroup
    var equipment : [String]
    var className : String
    var duration : String
    var startMessage : String
    var startState : TargetState
    var states : [TargetState]
}

enum Intensity: String, CaseIterable, Codable, Hashable {
    case high = "High"
    case low = "Low"
}

enum MuscleGroup: String, CaseIterable, Codable, Hashable {
    
    case legs = "Legs"
    case shoulders = "Shoulders"
    case wholeBody = "Whole body"
    
    public static func getIconName(_ muscleGroup: MuscleGroup) -> String {
        switch muscleGroup {
            case .legs: return "leg-icon"
            case .shoulders: return "shoulder-icon"
            case .wholeBody: return "whole-body-icon"
        }
    }
    
    public static func getIconColor(_ muscleGroup: MuscleGroup) -> UIColor {
        switch muscleGroup {
            case .legs: return .red
            case .shoulders: return .orange
            case .wholeBody: return .purple
        }
    }
    
    public static var allCases: [MuscleGroup] {
        return [.legs, .shoulders, .wholeBody]
    }
    
}
