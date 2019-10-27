//
//  ExerciseDetailView.swift
//  Testing UI
//
//  Created by Lloyd Clowes on 18/10/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI

struct ExerciseDetailView: View {
    
    @State private var searchQuery: String = ""
    
    let title: String
    var exercises: [Exercise]
    
    var body: some View {
        VStack{
            SearchBar(text: $searchQuery)
            List {
                ForEach(exercises.filter{$0.name.hasPrefix(searchQuery) || searchQuery == ""}, id:\.self){ exercise in
                ExerciseRowView(exercise: exercise,
                                 duration: "00:15",
                                 color: Color(red: 1.00, green: 0.98, blue: 0.98))
            }
            }
            Spacer()
        }
        .navigationBarTitle(Text(self.title))
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(
            title: "Core",
            exercises: [Exercise(id: 001, name: "Sit ups", intensity: .high, muscleGroup: .core, equipment: ["None"]), Exercise(id: 002, name: "Crunches", intensity: .low, muscleGroup: .core, equipment: ["None"])]
        )
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

