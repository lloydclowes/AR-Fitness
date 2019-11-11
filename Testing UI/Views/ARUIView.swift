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
    
    @State var counter: Int = 60
    
    var body: some View {
        return ZStack {
            ARViewControllerContainer($counter)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(exercise.name)
            VStack {
                Spacer()
                Text("Timer: \(counter)")
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
    
    let characterAnchor = AnchorEntity()
    var character: BodyTrackedEntity?
    @Binding var counter: Int
    
    init(_ counter: Binding<Int>) {
        _counter = counter
    }
    
    func makeCoordinator() -> Coordinator {}
    
    func makeUIViewController(context: Context) -> UIViewController {
        return LatController() //parent: self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    
    static var previews: some View {
        ARUIView(exercise: exerciseData[0])
    }
}
#endif
