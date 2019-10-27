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
    init(title: String, exercises: [Exercise]) {
        self.title = title
        self.exercises = exercises
        UINavigationBar.appearance().backgroundColor = UIColor(ciColor: .white)
    }
    var body: some View {
        VStack{
            SearchBar(text: $searchQuery)
                ForEach(exercises.filter{$0.name.hasPrefix(searchQuery) || searchQuery == ""}, id:\.self){ exercise in
                ExerciseRowView(exercise: exercise,
                                 duration: "00:15",
                                 color: Color(red: 1.00, green: 0.98, blue: 0.98)).padding()
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

