//
//  ExerciseRowView.swift
//  Testing UI
//
//  Created by Blanca Tebar on 19/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseRowView: View {
    
    var exercise: Exercise
    var color: Color
    
    private func getIntensityColor() -> Color {
        switch exercise.intensity {
            case .high:
                return .orange
            case .low:
                return .green
        }
    }
    
    var body: some View {
        HStack {
            VStack {
               // Intensity label style and text
                Text(self.exercise.intensity.rawValue.capitalized) .foregroundColor(getIntensityColor())
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .font(.system(size: 15))
       
               // Exercise label style and text
                Text(self.exercise.name.uppercased())
                    .foregroundColor(.black)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding(.bottom, 8)
                    .padding(.top, 8)
                    .font(.system(size: 23))
               
               // Equipment label style and text
                Text("Equipment: " + (self.exercise.equipment == [] ? "None" : self.exercise.equipment.map {$0.capitalized}.joined(separator: ", ")))
                    .foregroundColor(Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .font(.system(size: 15))
                
            }
            NavigationLink(destination: ARUIView(self.exercise)) {
                VStack {
                    Text("START")
                        .bold()
                        .font(.system(size:15))
                    Text(self.exercise.duration)
                        .font(.system(size:13))
                        .foregroundColor(Color.black)
                }
            }
            .foregroundColor(Color.black)
            .padding()
            .background(Color(red: 1.00, green: 0.5, blue: 0.5))
            .cornerRadius(25)
            .frame(minWidth: 0, maxWidth: 100)
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120)
        .background(color)
        .lineLimit(2)
        .cornerRadius(25)
    }
}

//struct ExerciseRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseRowView(
//            exercise: Exercise(id: 001, name: "Sit ups", intensity: .high, muscleGroup: .core, equipment: ["foo", "poo"], className: "ARUIViewController", duration: "2:00"),
//            color: Color(red: 1.00, green: 0.98, blue: 0.98)
//        ).padding()
//    }
//}
