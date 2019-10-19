//
//  ExerciseDetailView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseDetailView: View {
    
    let title: String
    var muscleGroupFilter: String?
    var intensityFilter: String?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Spacer()
                ExerciseRowView(exercise: "Sit ups",
                                 intensity: "high",
                                 equipement: "None",
                                 color: Color(red: 1.00, green: 0.98, blue: 0.98))
                Spacer()
                ExerciseRowView(exercise: "Crunches",
                                 intensity: "low",
                                 equipement: "None", color: Color(red: 1.00, green: 0.98, blue: 0.98))
                Spacer()
            }
            .padding()
            .navigationBarTitle(Text(self.title))
        }
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(title: "Core")
    }
}
