//
//  MuscleGroupsList.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 25/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct MuscleGroupsList: View {
    
    var exercises: [Exercise]
    
    private let icons = ["leg-icon", "arm-icon", "whole-body-icon", "core-icon"]
    private let enums: [MuscleGroup] = [.legs, .arms, .wholeBody, .core]
    private let colors: [UIColor] = [.red, UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1.0), .purple, .orange]
    
    var body: some View {
        List(0 ..< 4) { item in
            NavigationLink(destination: ExerciseDetailView(title: self.enums[item].rawValue, exercises: self.filterByMuscleGroup(exercises: self.exercises, muscleGroup: self.enums[item])
            )) {
                MuscleGroupRow(icon: self.icons[item], color: self.colors[item], iconSize: 33, muscleGroup: self.enums[item].rawValue)
            }
        }
        .background(Color.white)
        .cornerRadius(10)   
    }
    
    private func filterByMuscleGroup(exercises: [Exercise], muscleGroup: MuscleGroup) -> [Exercise] {
        return exercises.filter {
            switch $0.muscleGroup {
                case muscleGroup: return true
                default: return false
            }
        }
    }
    
}

struct MuscleGroupsList_Previews: PreviewProvider {
    static var previews: some View {
        MuscleGroupsList(exercises: [])
    }
}
