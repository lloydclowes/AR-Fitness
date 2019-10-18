//
//  ExerciseView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseView: View {
    
    private var exercises = ["Core", "Legs", "Arms", "Whole Body"]
    
    var body: some View {
        NavigationView {
            VStack() {
                Text("Select your type of workout:")
                    .font(.headline)
                NavigationLink(destination: ExerciseDetailView(title: "High Intensity", intensityFilter: "High")) {
                    IntensityButtonView(text: "High Intensity", color: .orange)
                }.padding()
                NavigationLink(destination: ExerciseDetailView(title: "Low Intensity", intensityFilter: "Low")) {
                    IntensityButtonView(text: "Low Intensity", color: .green)
                }.padding()
                Text("Or select the muscle group:")
                    .font(.headline)
                HStack(alignment: .center) {
                    Spacer()
                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[0], muscleGroupFilter: self.exercises[0])) {
                        ExerciseTileView(text: self.exercises[0], color: .red)
                    }
                    Spacer()
                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[1], muscleGroupFilter: self.exercises[1])) {
                        ExerciseTileView(text: self.exercises[1], color: .red)
                    }
                    Spacer()
                }.padding()
                HStack(alignment: .center) {
                    Spacer()
                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[2], muscleGroupFilter: self.exercises[2])) {
                        ExerciseTileView(text: self.exercises[2], color: .red)
                    }
                    Spacer()
                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[3], muscleGroupFilter: self.exercises[3])) {
                        ExerciseTileView(text: self.exercises[3], color: .red)
                    }
                    Spacer()
                }.padding()
            }
            .navigationBarTitle(Text("Exercises"))
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
