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

class LateralRaiseController: UIViewController, ARSessionDelegate {

    var arView = ARView(frame: .zero)
    
    var label0: String?
    var label2: String?
    var label3: String?

    var resetTimer: UIButton!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    var started = false
    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    // A tracked raycast which is used to place the character accurately
    // in the scene wherever the user taps.
    var placementRaycast: ARTrackedRaycast?
    var tapPlacementAnchor: AnchorEntity?
            
    var activityMonitor = ActivityMonitor([])
    var startState = ActivityState("START", [:], [:])
    
    var counter = 60
    var timer = Timer()
    var speaker = SpeechSynthesizer()
    
    var prevTime = Int(Date().timeIntervalSince1970)
    
    @IBAction func cancelTimerButtonTapped(sender: UIButton) {
        timer.invalidate()
    }

    @objc func timerAction() {
        counter -= 1
        label0 = "\(counter)"
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
       
    
    func roundToPlaces(_ f: Float, _ places: Int) -> Float {
        let k = Float(10 ^ places)
        let res = round(f * k) / k
        if res == 0 {
            return 0
        } else {
            return res
        }
    }
    
    func sf4RoundedToString(row: simd_float4) -> String {
        return "\(roundToPlaces(row[0], 3)) \(roundToPlaces(row[1], 3)) \(roundToPlaces(row[2], 3)) \(roundToPlaces(row[3], 3))"
    }
    
    // returns: actual < target   (including tolerance)
    func lowerTargetHit(_ actual: Float, _ target: Float, _ tolerance: Float) -> Bool {
        return actual < target + tolerance
    }
    
    // returns: actual > target   (including tolerance)
    func upperTargetHit(_ actual: Float, _ target: Float, _ tolerance: Float) -> Bool {
        return actual > target - tolerance
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
            
            
            characterAnchor.transform = Transform(matrix: bodyAnchor.transform)
            // ^ alternatively set .position and .orientation
            
            if activityMonitor.checkForStateAdvance(bodyAnchor) {
                timer.invalidate()
            }
            
            let curTime = Int(Date().timeIntervalSince1970)
            if (started && curTime - prevTime > 2) {
                prevTime = curTime
                let anglesLeft = bodyAnchor.getLocalJointAngleXYZ("left_arm_joint")
                let anglesRight = bodyAnchor.getLocalJointAngleXYZ("right_arm_joint")

                let lowerTol: Float = 7.5
                let upperTol: Float = -7.5

                var left = 0
                var right = 0
                if (anglesLeft.y?.sign == .plus && anglesLeft.y! > lowerTol) {
                    left = -1
                } else if (anglesLeft.y?.sign == .minus && anglesLeft.y! < upperTol) {
                    left = 1
                }

                if (anglesRight.y?.sign == .plus && anglesRight.y! > lowerTol) {
                    right = -1
                } else if (anglesRight.y?.sign == .minus &&  anglesRight.y! < upperTol ) {
                    right = 1
                }

                var phrase = ""
                if left != 0 {
                    phrase = "Please \(left == -1 ? "raise" : "lower") your left arm"
                }
                if right != 0 {
                    let dir = left == -1 ? "raise" : "lower"
                    if phrase == "" {
                        phrase = "Please \(dir) your right arm"
                    } else {
                        phrase += " and \(dir) your right arm"
                    }
                }

                if phrase != "" {
                    speaker.speak(statement: phrase)
                }
            }
            
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
         
            if let leftHipToKnee = bodyAnchor.getLocalJointAngleXYZ("left_arm_joint").y {
                label2 = "left: \(Int(leftHipToKnee))"
            }
            label3 = ""
            if let rightHipToKnee = bodyAnchor.getLocalJointAngleXYZ("right_arm_joint").y {
                label3 = "right: \(Int(rightHipToKnee))"
            }
            
            label0 = "Time: \(counter)"
        }
    }
    
    func setupViews() {
        view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
