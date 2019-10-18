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
            HStack(alignment: .center) {
                Spacer()
                ExerciseTileView(text: "Sit ups", color: .red)
                Spacer()
                ExerciseTileView(text: "Crunches", color: .red)
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
