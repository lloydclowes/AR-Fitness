////
////  ARViewController.swift
////  Testing UI
////
////  Created by Lloyd Clowes on 30/10/2019.
////  Copyright © 2019 SE Project Group 8. All rights reserved.
////
//
//import UIKit
//import SwiftUI
//import ARKit
//import RealityKit
//import Combine
//
//struct ARViewController: UIViewControllerRepresentable {
//
//    var controller: UIViewController
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UIPageViewController {
//        let pageViewController = UIPageViewController(
//            transitionStyle: .scroll,
//            navigationOrientation: .horizontal)
//        pageViewController.dataSource = context.coordinator as? UIPageViewControllerDataSource
//        pageViewController.delegate = context.coordinator as? UIPageViewControllerDelegate
//
//        return pageViewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIPageViewController, context: UIViewControllerRepresentableContext<ARViewController>) {
//        uiViewController.setViewControllers([controller], direction: .forward, animated: true)
//    }
//
//    class Coordinator: NSObject, ARSessionDelegate {
//
//        var parent: ARViewController
////        let characterAnchor = AnchorEntity()
////        var lateralRaiseMonitor = ActivityMonitor([])
////        var timer = Timer()
////        var character: BodyTrackedEntity?
////        var reps = 0
//
//        init(_ pageViewController: ARViewController) {
//            self.parent = pageViewController
//        }
//
////        override func viewDidAppear(_ animated: Bool) {
////            super.viewDidAppear(animated)
////            lateralRaiseView.session.delegate = self
////
////            // If the iOS device doesn't support body tracking, raise a developer error for
////            // this unhandled case.
////            guard ARBodyTrackingConfiguration.isSupported else {
////                fatalError("This feature is only supported on devices with an A12 chip")
////            }
////
////            // Run a body tracking configration.
////            let configuration = ARBodyTrackingConfiguration()
////            lateralRaiseView.session.run(configuration)
////            lateralRaiseView.scene.addAnchor(characterAnchor)
////
////            // Asynchronously load the 3D character.
////            var cancellable: AnyCancellable? = nil
////            cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
////                receiveCompletion: { completion in
////                    if case let .failure(error) = completion {
////                        print("Error: Unable to load model: \(error.localizedDescription)")
////                    }
////                    cancellable?.cancel()
////            }, receiveValue: { (character: Entity) in
////                if let character = character as? BodyTrackedEntity {
////                    // Scale the character to human size
////                    character.scale = [1.0, 1.0, 1.0]
////                    self.character = character
////                    cancellable?.cancel()
////                } else {
////                    print("Error: Unable to load model as BodyTrackedEntity")
////                }
////            })
////
////            let lateralRaiseState = ["left_arm_joint": EulerAngles(y: Float(0)),
////                                  "right_arm_joint": EulerAngles(y: Float(0))
////             ]
////
////            // 90 * 0.15 = 15% tolerance on 90 degrees of motion
////            let lateralTolerance = Float(5*0.15)
////
////            let standState = ["left_arm_joint": EulerAngles(y: Float(5)),
////                            "right_arm_joint": EulerAngles(y: Float(5))
////            ]
////            let lateralRaiseTolerances = ["left_arm_joint": EulerAngles(y: lateralTolerance),
////                            "right_arm_joint": EulerAngles(y: lateralTolerance)
////            ]
////            let standingTolerances = ["left_arm_joint": EulerAngles(y: -lateralTolerance),
////                            "right_arm_joint": EulerAngles(y: -lateralTolerance)
////            ]
////
////            self.lateralRaiseMonitor = ActivityMonitor([
////             ActivityState("DOWN", standState, standingTolerances),
////             ActivityState("UP", lateralRaiseState, lateralRaiseTolerances)
////            ])
////        }
////
////        func roundToPlaces(_ f: Float, _ places: Int) -> Float {
////             let k = Float(10 ^ places)
////             let res = round(f * k) / k
////             if res == 0 {
////                 return 0
////             } else {
////                 return res
////             }
////         }
////
////         func sf4RoundedToString(row: simd_float4) -> String {
////             return "\(roundToPlaces(row[0], 3)) \(roundToPlaces(row[1], 3)) \(roundToPlaces(row[2], 3)) \(roundToPlaces(row[3], 3))"
////         }
////
////         // returns: actual < target   (including tolerance)
////         func lowerTargetHit(_ actual: Float, _ target: Float, _ tolerance: Float) -> Bool {
////             return actual < target + tolerance
////         }
////
////         // returns: actual > target   (including tolerance)
////         func upperTargetHit(_ actual: Float, _ target: Float, _ tolerance: Float) -> Bool {
////             return actual > target - tolerance
////         }
////
////         func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
////             for anchor in anchors {
////                 guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
////
////                 characterAnchor.transform = Transform(matrix: bodyAnchor.transform)
////                 // ^ alternatively set .position and .orientation
////
////                 if lateralRaiseMonitor.checkForStateAdvance(bodyAnchor) {
////                     timer.invalidate()
////                 }
////
////                 if let character = character, character.parent == nil {
////                     // Attach the character to its anchor as soon as
////                     // 1. the body anchor was detected and
////                     // 2. the character was loaded.
////                     characterAnchor.addChild(character)
////                 }
////
////             }
////         }
//
//    }
//}
//
//struct ARViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        ARViewController()
//    }
//}
