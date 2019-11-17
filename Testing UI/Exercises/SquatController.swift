/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine

class SquatController: UIViewController, ARSessionDelegate {

    var arView = ARView(frame: .zero)
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    // A tracked raycast which is used to place the character accurately
    // in the scene wherever the user taps.
    var placementRaycast: ARTrackedRaycast?
    var tapPlacementAnchor: AnchorEntity?
    
    var activityMonitor: ActivityMonitor?
    let speaker = SpeechSynthesizer()

    var upDirection = false
    var reps = 0
    var initial = true
    var reachedSquat = false
    
    let infoLabel : UILabel = {
        let myLabel = UILabel()
        myLabel.textColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        myLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        myLabel.font = UIFont.boldSystemFont(ofSize: 20)
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.adjustsFontSizeToFitWidth = true
        return myLabel
    }()
    
    override func viewDidLoad() {
        infoLabel.text = "Reps: \(reps)"
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            arView.session.delegate = self
            
            // If the iOS device doesn't support body tracking, raise a developer error for
            // this unhandled case.
            guard ARBodyTrackingConfiguration.isSupported else {
                fatalError("This feature is only supported on devices with an A12 chip")
            }

            // Run a body tracking configration.
            let configuration = ARBodyTrackingConfiguration()
            arView.session.run(configuration)
            arView.scene.addAnchor(characterAnchor)
            
            // Asynchronously load the 3D character.
            var cancellable: AnyCancellable? = nil
            cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error: Unable to load model: \(error.localizedDescription)")
                    }
                    cancellable?.cancel()
            }, receiveValue: { (character: Entity) in
                if let character = character as? BodyTrackedEntity {
                    // Scale the character to human size
                    character.scale = [1.0, 1.0, 1.0]
                    self.character = character
                    cancellable?.cancel()
                } else {
                    print("Error: Unable to load model as BodyTrackedEntity")
                }
            })
            
    //        let almostSquattedState = ["left_upLeg_joint": EulerAngles(y: Float(45)),
    //                             "right_upLeg_joint": EulerAngles(y: Float(45)),
    //                             "left_leg_joint": EulerAngles(z: Float(45)),
    //                             "right_leg_joint": EulerAngles(z: Float(45))
    //        ]
            //        let improvementTol = Float(50 * 0.05)

            
            // 90 * 0.15 = 15% tolerance on 90 degrees of motion
            let upLegTol = Float(90 * 0.15)
            // 90 * 0.15 = 15% tolerance on 70 degrees of motion
            let legTol = Float(70 * 0.15)
            
            let uprightState = ["left_upLeg_joint":  EulerAngles(z: Float(-90)),
                                "right_upLeg_joint": EulerAngles(z: Float(90)),
                                "left_leg_joint": EulerAngles(z: Float(20)),
                                "right_leg_joint": EulerAngles(z: Float(20))
            ]
            
            let uprightTolerances = ["left_upLeg_joint": EulerAngles(z: upLegTol),
                                     "right_upLeg_joint": EulerAngles(z: -upLegTol),
                                     "left_leg_joint": EulerAngles(z: legTol),
                                     "right_leg_joint": EulerAngles(z: legTol)
            ]
            
            let squattedState = ["left_upLeg_joint": EulerAngles(z: Float(0)),
                                 "right_upLeg_joint": EulerAngles(z: Float(0)),
                                 "left_leg_joint": EulerAngles(z: Float(90)),
                                 "right_leg_joint": EulerAngles(z: Float(90))
            ]
            
            let squattedTolerances = ["left_upLeg_joint": EulerAngles(z: -upLegTol),
                                      "right_upLeg_joint": EulerAngles(z: upLegTol),
                                      "left_leg_joint": EulerAngles(z: -legTol),
                                      "right_leg_joint": EulerAngles(z: -legTol)
            ]
            
    //        let improvementTolerances = ["left_upLeg_joint": EulerAngles(x: improvementTol),
    //                                  "right_upLeg_joint": EulerAngles(x: improvementTol),
    //                                  "left_leg_joint": EulerAngles(x: improvementTol),
    //                                  "right_leg_joint": EulerAngles(x: improvementTol)
    //        ]
                    
            self.activityMonitor = ActivityMonitor([
                ActivityState("UP", uprightState, uprightTolerances),
                ActivityState("DOWN", squattedState, squattedTolerances)
            ])
    //        ], improvableStates: [ActivityState("UP", uprightState, uprightTolerances), ActivityState("DEEPER", almostSquattedState, improvementTolerances)])
        }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            characterAnchor.transform = Transform(matrix: bodyAnchor.transform)
            // ^ or independently set .orientation and .position of characterAnchor
            
            if let character = character, character.parent == nil {
                characterAnchor.addChild(character)
            }
            
//            if squatMonitor.checkForImprovement(bodyAnchor) {
//                if squatMonitor.improvableIndex == 1 && !reachedSquat && !initial {
//                    print("CONSOLE")
//                    speaker.speak(statement: "go deeper")
//                }
//            }
            
            if self.activityMonitor!.checkForStateAdvance(bodyAnchor) {
                self.reps += (self.activityMonitor!.index == 1 && !initial) ? 1 : 0
                self.reachedSquat = self.activityMonitor!.index == 0
                 if initial { initial = false }
            }
        
            self.infoLabel.text = "Reps: \(reps)"
        }
    }
    
    func setupViews() {
        // adding both views
        view.addSubview(arView)
        view.addSubview(infoLabel)
        
        // label constraints (position, size...)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 40))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -40))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        
        // arView constraints
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func resetRepCount(_ sender: UIButton) {
        self.reps = 0
        self.infoLabel.text = "Reps: \(reps)"
    }
    
}
