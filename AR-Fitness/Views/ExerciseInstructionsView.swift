//
//  ExerciseInstructionsView.swift
//  AR-Fitness
//
//  Created by Blanca Tebar on 28/11/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ExerciseInstructionsView: View {
    var exercise : String
    
    var body: some View {
        return ExerciseInstructionControllerContainer(exercise: exercise)
                .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("\(exercise) guide")
    }
}

struct ExerciseInstructionControllerContainer: UIViewControllerRepresentable {
    let characterAnchor = AnchorEntity()
    var character: BodyTrackedEntity?
    var exercise: String
    
    func makeCoordinator() -> Coordinator {}
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch self.exercise {
        case "Lateral Raises":
            return LateralRaiseController()
        case "Squats":
            return SlowSquatController()
        default:
            return SquatController()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ExerciseInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseInstructionsView(exercise: "Hello")
    }
}
