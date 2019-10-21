//
//  ExerciseView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseView: View {
    
    var exerciseName: String
    var duration: String
    var equipment: String
    var intensity: String
    
    var body: some View {
        Text("This is where the arkit stuff goes")
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(exerciseName: "squats", duration: "00:30", equipment: "None", intensity: "Low")
    }
}
