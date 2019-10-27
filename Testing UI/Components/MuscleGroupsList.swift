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
    
    private let exerciseNames = ["Legs", "Arms", "Whole Body", "Core"]
    private let icons = ["leg-icon", "arm-icon", "whole-body-icon", "core-icon"]
    private let enums: [MuscleGroup] = [.legs, .arms, .wholeBody, .core]
    private let colors: [UIColor] = [.red, .blue, .purple, .orange]
    
    var body: some View {
        List(0 ..< 4) { item in
            NavigationLink(destination: ExerciseDetailView(title: self.exerciseNames[item], exercises: self.exercises.filter {
                    switch $0.muscleGroup {
                        case self.enums[item]: return true
                            default: return false
                        }
                    }
            )) {
                MuscleGroupRow(icon: self.icons[item], color: self.colors[item], iconSize: 33, muscleGroup: self.exerciseNames[item])
            }
        }
        .background(Color.white)
        .cornerRadius(10)
    }
    
}

struct MuscleGroupsList_Previews: PreviewProvider {
    static var previews: some View {
        MuscleGroupsList(exercises: [])
    }
}
