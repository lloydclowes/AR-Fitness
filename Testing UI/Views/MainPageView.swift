//
//  MainPageView.swift
//  Testing UI
//
//  Created by Blanca Tebar on 21/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//
import SwiftUI

struct MainPageView: View {
    
    private var exercises = ["Legs", "Arms", "Whole Body", "Core"]
    private var icons = ["leg-icon", "arm-icon", "whole-body-icon", "leg-icon"]
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
    }
    
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
                HStack {
                    Text("Muscle groups")
                        .font(.system(size: 20, weight: .bold))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                List(0 ..< 4) { item in
                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[item], muscleGroupFilter: self.exercises[item])) {
                        HStack {
                            IconView(iconName: self.icons[item], color: .blue, size: 33)
                            Text(self.exercises[item])
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                            }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                
                Spacer()
//                HStack(alignment: .center) {
//                    Spacer()
//                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[0], muscleGroupFilter: self.exercises[0])) {
//                        ExerciseTileView(text: self.exercises[0], color: Color(red: 1.00, green: 0.98, blue: 0.98))
//                    }
//                    Spacer()
//                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[1], muscleGroupFilter: self.exercises[1])) {
//                        ExerciseTileView(text: self.exercises[1], color: Color(red: 1.00, green: 0.98, blue: 0.98))
//                    }
//                    Spacer()
//                }.padding()
//                HStack(alignment: .center) {
//                    Spacer()
//                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[2], muscleGroupFilter: self.exercises[2])) {
//                        ExerciseTileView(text: self.exercises[2], color: Color(red: 1.00, green: 0.98, blue: 0.98))
//                    }
//                    Spacer()
//                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[3], muscleGroupFilter: self.exercises[3])) {
//                        ExerciseTileView(text: self.exercises[3], color: Color(red: 1.00, green: 0.98, blue: 0.98))
//                    }
//                    Spacer()
//                }.padding()
            }
            .padding()
            .navigationBarTitle(Text("Exercises"))
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
    }
}
