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
    
    private let muscleGroups: [MuscleGroup] = MuscleGroup.allCases
    
    var body: some View {
        List(0 ..< muscleGroups.count) { item in
            NavigationLink(destination: ExerciseDetailView(title: self.muscleGroups[item].rawValue, exercises: self.filterByMuscleGroup(exercises: self.exercises, muscleGroup: self.muscleGroups[item])
            )) {
                MuscleGroupRow(icon: MuscleGroup.getIconName(self.muscleGroups[item]), color: MuscleGroup.getIconColor(self.muscleGroups[item]), iconSize: 33, muscleGroup: self.muscleGroups[item].rawValue)
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
