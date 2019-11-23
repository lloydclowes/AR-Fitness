/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine

class HundredUpsController: UIViewController, ARSessionDelegate {

    var arView = ARView(frame: .zero)
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    // A tracked raycast which is used to place the character accurately
    // in the scene wherever the user taps.
    var placementRaycast: ARTrackedRaycast?
    var tapPlacementAnchor: AnchorEntity?
    
    var activityMonitor = ActivityMonitor()
    let speaker = SpeechSynthesizer()

    var upDirection = false
    var reps = 0
    var initial = true
    var reachedSquat = false
    
    var showRobot = false
    
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

        self.activityMonitor = ActivityMonitor(exerciseData[2].states)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    //        let leftLegUpImprState = ["left_upLeg_joint": EulerAngles(y: Float(-70))]
    //        let rightLegUpImprState = ["right_upLeg_joint": EulerAngles(y: Float(-70))]
    //        let downTol = Float(70 * 0.15)
    //        let leftLegUpImprTolerances = ["left_upLeg_joint": EulerAngles(y: downTol)]
    //        let rightLegUpImprTolerances = ["right_upLeg_joint": EulerAngles(y: downTol)]
            
            for anchor in anchors {
                guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
                
                characterAnchor.transform = Transform(matrix: bodyAnchor.transform)
                // ^ or independently set .orientation and .position of characterAnchor
                
                if let character = character, character.parent == nil {
                    characterAnchor.addChild(character)
                }
                characterAnchor.isEnabled = showRobot
                
//                if activityMonitor.checkForStateAdvance(bodyAnchor) {
//                    reps += activityMonitor.index == 1 ? 1 : 0
//                }
                
                let prevState = activityMonitor.index
                let target = activityMonitor.targetIndex
                let newState = activityMonitor.updateState(bodyAnchor)
                if newState != prevState && newState != -1 {
                    if newState == target && newState == 0 && activityMonitor.lastSuccess {
                        reps += 1
                    }
                }

//                let ruz = bodyAnchor.getLocalJointAngleXYZ("right_upLeg_joint").z
//                let rlz = bodyAnchor.getLocalJointAngleXYZ("right_leg_joint").z
//                let luz = bodyAnchor.getLocalJointAngleXYZ("left_upLeg_joint").z
//                let llz = bodyAnchor.getLocalJointAngleXYZ("left_leg_joint").z
                
                self.infoLabel.text = "Reps: \(reps)"
//                self.rlzLabel.text = "ruz: \(Int(ruz!))  rlz: \(Int(rlz!))"
//                self.llzLabel.text = "luz: \(Int(luz!))  llz: \(Int(llz!))"
            }
        }
    
    func setupViews() {
        // adding both views
        view.addSubview(arView)
        view.addSubview(infoLabel)
//        view.addSubview(rlzLabel)
//        view.addSubview(llzLabel)
        
        // label constraints (position, size...)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 40))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -40))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        
//        rlzLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addConstraint(NSLayoutConstraint(item: rlzLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -150))
//        self.view.addConstraint(NSLayoutConstraint(item: rlzLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 40))
//        self.view.addConstraint(NSLayoutConstraint(item: rlzLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -40))
//        self.view.addConstraint(NSLayoutConstraint(item: rlzLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
//
//        llzLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addConstraint(NSLayoutConstraint(item: llzLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -225))
//        self.view.addConstraint(NSLayoutConstraint(item: llzLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 40))
//        self.view.addConstraint(NSLayoutConstraint(item: llzLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -40))
//        self.view.addConstraint(NSLayoutConstraint(item: llzLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        
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
