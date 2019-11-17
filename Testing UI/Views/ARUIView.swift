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
    var viewControllerContainer = ARViewControllerContainer()
    
    init(_ exe: Exercise) {
        exercise = exe
    }
    
    
    var body: some View {
           return viewControllerContainer
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(exercise.name)
    }
}

struct ARViewControllerContainer: UIViewControllerRepresentable {
    let characterAnchor = AnchorEntity()
    var character: BodyTrackedEntity?
    
    func makeCoordinator() -> Coordinator {}
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = LatController()
        return viewController
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
