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
    
    var exercises: [Exercise] = exerciseData
    
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
                    exercises: filterByIntensity(exercises: self.exercises, intensity: .high)
                )) {
                    IntensityButtonView(text: "High Intensity", color: .orange)
                }.padding()
                NavigationLink(destination: ExerciseDetailView(
                    title: "Low Intensity",
                    exercises: filterByIntensity(exercises: self.exercises, intensity: .low)
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
                MuscleGroupsList(exercises: self.exercises)
                    .frame(height: 258)
                Spacer()
            }.navigationBarTitle(Text("Exercises"))
            .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.95)).edgesIgnoringSafeArea(.bottom)
        }
        
    }
    
    private func filterByIntensity(exercises: [Exercise], intensity: Intensity) -> [Exercise] {
        return exercises.filter {
            switch $0.intensity {
                case intensity: return true
                default: return false
            }
        }
    }
    
}


struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
    }
}
