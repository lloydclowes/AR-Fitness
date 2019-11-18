//
//  ARUIView.swift
//  AR-Sports
//
//  Created by Brandon Forbes on 15/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARUIView : View {
    
    var exercise: Exercise
    
    init(_ exe: Exercise) {
        exercise = exe
    }
    
    var body: some View {
           return ARViewControllerContainer(exercise: exercise)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(exercise.name)
    }
}

struct ARViewControllerContainer: UIViewControllerRepresentable {
    let characterAnchor = AnchorEntity()
    var character: BodyTrackedEntity?
    var exercise: Exercise
    
    func makeCoordinator() -> Coordinator {}
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        switch self.exercise.name {
        case "Lateral Raises":
            return LateralRaiseController()
        case "Squats":
            return SquatController()
        case "Hundred Ups":
            return HundredUpsController()
        default:
            return ARUIViewController()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    
    static var previews: some View {
        ARUIView(exerciseData[0])
    }
}
#endif
