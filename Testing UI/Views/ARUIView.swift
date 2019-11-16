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
    
    @EnvironmentObject var counter: ControlVariable
    var viewControllerContainer = ARViewControllerContainer()
    
    init(_ exe: Exercise) {
        exercise = exe
    }
    
    
    var body: some View {
        return ZStack {
            viewControllerContainer.environmentObject(self.counter)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(exercise.name)
            VStack {
                Spacer()
                Text("Timer: \(self.counter.counter)")
                    .font(.largeTitle)
                    .background(Circle()
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .frame(width: 150, height: 150)
                    )
                    .padding([.bottom], 50)
            }
        }
    }
}

struct ARViewControllerContainer: UIViewControllerRepresentable {
     @EnvironmentObject var counter: ControlVariable
    
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
