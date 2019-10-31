//
//  ContentView.swift
//  AR-Sports
//
//  Created by Brandon Forbes on 15/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ContentView : View {
    var body: some View {
        return ARViewContainer()
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let characterAnchor = AnchorEntity()
    var character: BodyTrackedEntity?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
        let arView = ARView(frame: .zero)
        
        // Run a body tracking configration.
        arView.session.run(ARBodyTrackingConfiguration())
        arView.scene.addAnchor(characterAnchor)
        
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                context.coordinator.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    class Coordinator: NSObject {
        
        var parent: ARViewContainer
        var character: BodyTrackedEntity?
        var timer = Timer()
//        var lateralRaiseMonitor = ActivityMonitor([])?

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
             for anchor in anchors {
                 guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
                 
                self.parent.characterAnchor.transform = Transform(matrix: bodyAnchor.transform)
                 // ^ alternatively set .position and .orientation
                 
//                if self.lateralRaiseMonitor.checkForStateAdvance(bodyAnchor) {
//                     timer.invalidate()
//                 }
        
                 if let character = character, character.parent == nil {
                     // Attach the character to its anchor as soon as
                     // 1. the body anchor was detected and
                     // 2. the character was loaded.
                    self.parent.characterAnchor.addChild(character)
                 }
                 
             }
         }

    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
