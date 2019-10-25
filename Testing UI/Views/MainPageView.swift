//
//  MainPageView.swift
//  Testing UI
//
//  Created by Blanca Tebar on 21/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//
import SwiftUI

struct MainPageView: View {
    
    @State private var searchQuery: String = ""
    
    var exerciseStructs: [Exercise] = [Exercise(id: 001, name: "Sit ups", intensity: .high, muscleGroup: .core, equipment: ["None"]), Exercise(id: 002, name: "Crunches", intensity: .low, muscleGroup: .core, equipment: ["None"]), Exercise(id: 003, name: "Lunges", intensity: .low, muscleGroup: .legs, equipment: ["None"])]
    
    private var exercises = ["Legs", "Arms", "Whole Body", "Core"]
    private var icons = ["leg-icon", "arm-icon", "whole-body-icon", "core-icon"]
    private var enums: [MuscleGroup] = [.legs, .arms, .wholeBody, .core]
    private var colors: [UIColor] = [.red, .blue, .purple, .orange]
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        
//        var exerciseData: Data = Data()
//        do {
//            exerciseData = try Data(contentsOf: URL(fileURLWithPath: "exerciseData.json"), options: .mappedIfSafe)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        let decoder = JSONDecoder()
//        exerciseStructs = []
//        do {
//            self.exerciseStructs = try decoder.decode([Exercise].self, from: exerciseData)
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    
    var body: some View {
        NavigationView {
            VStack() {
                Text("Select your type of workout:")
                    .font(.headline)
                NavigationLink(destination: ExerciseDetailView(
                    title: "High Intensity",
                    exercises: self.exerciseStructs.filter {
                        switch $0.intensity {
                        case .high: return true
                            default: return false
                        }
                    }
                )) {
                    IntensityButtonView(text: "High Intensity", color: .orange)
                }.padding()
                NavigationLink(destination: ExerciseDetailView(
                    title: "Low Intensity",
                    exercises: self.exerciseStructs.filter {
                        switch $0.intensity {
                            case .low: return true
                                default: return false
                            }
                        }
                    )) {
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
                    NavigationLink(destination: ExerciseDetailView(title: self.exercises[item], exercises: self.exerciseStructs.filter {
                            switch $0.muscleGroup {
                            case self.enums[item]: return true
                                default: return false
                            }
                        }
                    )) {
                        MuscleGroupRow(icon: self.icons[item], color: self.colors[item], iconSize: 33, muscleGroup: self.exercises[item])
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                Spacer()
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
