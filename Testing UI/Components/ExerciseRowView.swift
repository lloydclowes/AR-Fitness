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
    var equipment: String
    var duration: String
    var color: Color
    
    @State var showAlert = false
    
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
        HStack {
            VStack {
               // Intensity label style and text
                Text(self.intensity.capitalized).foregroundColor(getIntensityColor(level: self.intensity)).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading)
                    .font(.system(size: 15))
       
               // Exercise label style and text
                Text(self.exercise.uppercased()).foregroundColor(.black).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading)
                    .padding(.bottom, 8)
                    .padding(.top, 8)
                .font(.system(size: 23))
               
               // Equipment label style and text
                Text("Equipment: " + self.equipment.capitalized).foregroundColor(Color.gray).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding(.leading)
                    .font(.system(size: 15))
                
            }
            
            Button(action: {
              self.showAlert = true
            }) {
                VStack {
                    Text("START").bold().font(.system(size:15))
                    Text(self.duration).font(.system(size:13)).foregroundColor(Color.black)
                }
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("STARTED"))
                }.foregroundColor(Color.black).padding().background(Color(red: 1.00, green: 0.5, blue: 0.5)).cornerRadius(25)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120)
        .background(color)
        .lineLimit(2)
        .cornerRadius(25)
    }
}

struct ExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRowView(exercise: "Exercise example", intensity: "high", equipment: "None", duration: "00:15", color: Color(red: 1.00, green: 0.98, blue: 0.98)).padding()
    }
}
