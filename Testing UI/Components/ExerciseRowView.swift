//
//  ExerciseRowView.swift
//  Testing UI
//
//  Created by Blanca Tebar on 19/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseRowView: View {
    
    var exercise: String
    var intensity: String
    var equipement: String
    var color: Color
    
    func getIntensityColor(level: String) -> Color {
        switch level {
        case "high":
            return Color.green
        case "low":
            return Color.orange
        default:
            return Color.black
        }
    }
    
    var body: some View {
        VStack {
            Text(self.intensity.capitalized).foregroundColor(getIntensityColor(level: self.intensity)).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading)
                .font(.system(size: 15))
   
            Text(self.exercise.uppercased()).foregroundColor(.black).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading)
                .padding(.bottom, 8)
                .padding(.top, 8)
            .font(.system(size: 23))
           
            
            Text("Equipement: " + self.equipement.capitalized).foregroundColor(Color.gray).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading)
                .font(.system(size: 15))
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120)
        .background(color)
        .lineLimit(2)
        .cornerRadius(25)
    }
}

struct ExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRowView(exercise: "Hello hello", intensity: "high", equipement: "None", color: Color(red: 1.00, green: 0.98, blue: 0.98)).padding()
    }
}
