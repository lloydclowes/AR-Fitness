/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine
import SwiftUI

class LatController: UIViewController, ARSessionDelegate {

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
    var started = false
    var startState = ActivityState("START", [:], [:])
    var timer = Timer()
    var counter = 60
    var prevTime = Int(Date().timeIntervalSince1970)
    
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
        infoLabel.text = "Timer: \(counter)"
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
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
        
        let lateralRaiseState = [
            "left_arm_joint": EulerAngles(y: Float(0)),
            "right_arm_joint": EulerAngles(y: Float(0))
        ]
    
        
       // 90 * 0.15 = 15% tolerance on 90 degrees of motion
       let lateralTolerance = Float(50*0.15)
        
       let standState = ["left_arm_joint": EulerAngles(y: Float(50)),
                       "right_arm_joint": EulerAngles(y: Float(50))
       ]
       let lateralRaiseTolerances = ["left_arm_joint": EulerAngles(y: lateralTolerance),
                       "right_arm_joint": EulerAngles(y: lateralTolerance)
       ]
       let standingTolerances = ["left_arm_joint": EulerAngles(y: -lateralTolerance),
                       "right_arm_joint": EulerAngles(y: -lateralTolerance)
       ]
    
       startState = ActivityState("START", lateralRaiseState, lateralRaiseTolerances)

       
       self.activityMonitor = ActivityMonitor([
        ActivityState("DOWN", standState, standingTolerances),
        ActivityState("UP", lateralRaiseState, lateralRaiseTolerances)
       ])
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            if (!started && startState.reachedBy(bodyAnchor)) {
                speaker.start()
                started = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                    RunLoop.current.add(self.timer, forMode: .common)
                }
            }
            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
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
    
    @objc func timerAction() {
        counter -= 1
        infoLabel.text = "Timer: \(self.counter)"
    }
    
    
    
}





