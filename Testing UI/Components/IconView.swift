//
//  IconView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 24/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct IconView: View {
    
    var iconName: String
    var color: UIColor = .black
    var size: Int
    
    var body: some View {
        Image(
            uiImage: UIImage(named: self.iconName)!
                .withTintColor(self.color, renderingMode: .alwaysTemplate)
        )
        .resizable()
        .frame(width: CGFloat(self.size), height: CGFloat(self.size))
            .foregroundColor(Color(self.color))
    }
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        IconView(iconName: "leg-icon", color: .purple, size: 100)
    }
}
