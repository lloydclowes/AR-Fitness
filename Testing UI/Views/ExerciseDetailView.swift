//
//  ExerciseDetailView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseDetailView: View {
    
    @State private var searchQuery: String = ""
    
    let title: String
    var exercises: [Exercise]
    
    var body: some View {
        VStack{
            List(self.exercises) { exercise in
                ExerciseRowView(exercise: exercise,
                                 duration: "00:15",
                                 color: Color(red: 1.00, green: 0.98, blue: 0.98))
            }
            Spacer()
        }
        .navigationBarTitle(Text(self.title))
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(
            title: "Core",
            exercises: exerciseData.filter {
                switch $0.muscleGroup {
                case .core: return true
                    default: return false
                }
            }
        )
    }
}

