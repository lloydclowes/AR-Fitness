/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine

class LateralRaiseController: UIViewController, ARSessionDelegate {

    var arView = ARView(frame: .zero)
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    let speaker = SpeechSynthesizer.globalSpeaker
    
    var activityMonitor = ActivityMonitor()
    
    var countedDown = false
    var halfReward = false
    var fiveReward = false
    var completed = false
    
    var startTime = TimeInterval()
    var prevTime = TimeInterval()
    
    var showRobot = false
    
    let infoLabel : UILabel = {
        let myLabel = UILabel()
        myLabel.textColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        myLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        myLabel.font = UIFont.boldSystemFont(ofSize: 20)
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.adjustsFontSizeToFitWidth = true
        myLabel.clipsToBounds = true
        myLabel.layer.cornerRadius = 25
        return myLabel
    }()
    
    func infoButton() -> UIButton {
        let button : UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        button.setAttributedTitle(NSAttributedString(string: "See info", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor:
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)]), for: UIControl.State.normal)
        button.addTarget(nil, action: #selector(self.showInformation), for: UIControl.Event.touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    }
    
    override func viewDidLoad() {
        prevTime = Date().timeIntervalSince1970
        
        let exercise = exerciseData[Exercises.lateralRaise.rawValue]
        activityMonitor = ActivityMonitor(exercise.states, useTurningPoints: true)
        infoLabel.text = "Timer: \(Int(round(activityMonitor.remainingDuration)))"
        
        setupViews()
    }
    
    @IBAction func showInformation(sender: UIButton) {
        let modalViewController = ModalViewController()
        // TODO: This shouldn't be fixed at 60
        modalViewController.updateInfo(nil, timer: (60-Int(round(activityMonitor.remainingDuration)))*60, exerciseName: "Lateral Raises")
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: {})
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
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            characterAnchor.transform = Transform(matrix: bodyAnchor.transform)
            // ^ or independently set .orientation and .position of characterAnchor
            
            if let character = character, character.parent == nil {
                characterAnchor.addChild(character)
            }
            characterAnchor.isEnabled = showRobot
            
            let curTime = Date().timeIntervalSince1970
            let delta = curTime - prevTime
            prevTime = curTime
            activityMonitor.updateState(bodyAnchor, delta)
            if !activityMonitor.started {
                // TODO: every n seconds repeat "Please assume the start position"
                return
            }
            
            if !countedDown {
                speaker.countdown()
                startTime = Date().timeIntervalSince1970
                countedDown = true
            }
            
            if curTime - startTime > 3 {
                infoLabel.text = "Timer: \(Int(round(activityMonitor.remainingDuration)))"
                if !halfReward && round(activityMonitor.remainingDuration) <= 30 {
                    halfReward = true
                    speaker.speak(statement: "Half way there!")
                } else if !fiveReward && round(activityMonitor.remainingDuration) <= 5 {
                    fiveReward = true
                    speaker.speak(statement: "Only five more seconds!")
                } else if !completed && round(activityMonitor.remainingDuration) <= 0 {
                    speaker.speak(statement: "Well done! You've completed the challenge")
                    completed = true
    //                activityMonitor.reset()
    //                started = false
    //                halfReward = false
    //                fiveReward = false
                }
            }
        }
    }
            
            // TODO: swap 1 for startIndex
//            if activityMonitor.index != 1 {
//                timer.invalidate()
//            }
//
//            if (!started && startState.reachedBy(activityMonitor.currentState)) {
//                speaker.countdown()
//                started = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
//                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
//                    RunLoop.current.add(self.timer, forMode: .common)
//                }
//            }
//
//            if (started && delta > 2.0) {
//                prevTime = curTime
//                let anglesLeft = bodyAnchor.getLocalJointAngleXYZ("left_arm_joint")
//                let anglesRight = bodyAnchor.getLocalJointAngleXYZ("right_arm_joint")
//
//                let lowerTol: Float = 10.0
//                let upperTol: Float = -10.0
//
//                var left = 0
//                var right = 0
//                if (anglesLeft.y?.sign == .plus && anglesLeft.y! > lowerTol) {
//                    left = -1
//                } else if (anglesLeft.y?.sign == .minus && anglesLeft.y! < upperTol) {
//                    left = 1
//                }
//
//                if (anglesRight.y?.sign == .plus && anglesRight.y! > lowerTol) {
//                    right = -1
//                } else if (anglesRight.y?.sign == .minus &&  anglesRight.y! < upperTol ) {
//                    right = 1
//                }
//
//                var phrase = ""
//                if left != 0 {
//                    phrase = "Please \(left == -1 ? "raise" : "lower") your left arm"
//                }
//                if right != 0 {
//                    let dir = left == -1 ? "raise" : "lower"
//                    if phrase == "" {
//                        phrase = "Please \(dir) your right arm"
//                    } else {
//                        phrase += " and \(dir) your right arm"
//                    }
//                }
//
//                if phrase != "" {
//                    speaker.speak(statement: phrase)
//                }
    
    func setupViews() {
        let button = infoButton()
        view.addSubview(arView)
        view.addSubview(infoLabel)
        view.addSubview(button)
        
        // label constraints (position, size...)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 30))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 30))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 150))
        
        // button constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: infoLabel, attribute: .trailing, multiplier: 1, constant: 100))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 150))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        
        // arView constraints
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
//    @objc func startActivity() {
//        started = true
//    }
//    @objc func timerAction() {
//        counter -= 1
//        print(counter)
//        infoLabel.text = "Timer: \(self.counter)"
//        if(counter == 30) {
//            speaker.speak(statement: "Half way there!")
//        } else if(counter == 5) {
//            speaker.speak(statement: "Only five more seconds!")
//        } else if(counter == 0) {
//            speaker.speak(statement: "Well done! You've completed the challenge")
//        }
//    }
}





