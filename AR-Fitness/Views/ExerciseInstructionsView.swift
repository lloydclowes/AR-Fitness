//
//  ExerciseInstructionsView.swift
//  AR-Fitness
//
//  Created by Blanca Tebar on 28/11/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseInstructionsView: View {
    var exercise : String
    
    var body: some View {
        Text("Exercise: \(exercise). Instructions of how to perform this exercise accurately will go here")
    }
}

struct ExerciseInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseInstructionsView(exercise: "Hello")
    }
}
