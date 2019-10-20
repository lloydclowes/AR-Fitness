//
//  ExerciseTileView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseTileView: View {
    
    var text: String
    var color: Color
    
    var body: some View {
        Text(self.text.uppercased())
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120)
            .background(color)
            .foregroundColor(.black)
            .shadow(radius: 7)
            .font(.system(size: 23))
            .lineLimit(2)
            .cornerRadius(25)
    }
}

struct ExerciseTileView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseTileView(text: "Hello world", color: Color(red: 1.00, green: 0.98, blue: 0.98))
    }
}
