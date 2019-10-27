//
//  ExerciseView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseView: View {
    
    var exercise: Exercise
    
    var body: some View {
        Text("This is where the arkit stuff goes")
            .navigationBarTitle(Text(self.exercise.name))
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(exercise: exerciseData[0])
    }
}
