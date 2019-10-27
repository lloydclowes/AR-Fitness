//
//  IntensityButtonView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct IntensityButtonView: View {
    
    var text: String
    let color: Color
    
    var body: some View {
        Text(self.text.uppercased())
            .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width * 0.8, minHeight: 80, maxHeight: 80)
            .background(self.color)
            .foregroundColor(.white)
            .font(.system(size: 23))
            .lineLimit(2)
            .cornerRadius(35)
    }
}

struct IntensityButtonView_Previews: PreviewProvider {
    static var previews: some View {
        IntensityButtonView(text: "High intensity", color: .orange)
    }
}
