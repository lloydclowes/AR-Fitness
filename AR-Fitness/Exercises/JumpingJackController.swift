//
//  JumpingJackController.swift
//  AR-Fitness
//
//  Created by Group 8 on 02/01/2020.
//  Copyright © 2020 SE Project Group 8. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class JumpingJackController: UIViewController, ARSessionDelegate {
    
    var arView = ARView(frame: .zero)
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0]
    let characterAnchor = AnchorEntity()

    var uploaded = false
    let recordingSession = RecordingSession()

    
    var startTime = Double.greatestFiniteMagnitude
    
    var initial = true
    var reachedSquat = false
    var timer = Timer()
    var counter = 0
    let speaker = SpeechSynthesizer.globalSpeaker
    var rewarded = false

    var showRobot = true
    var label = "Hide"
    
    var activityMonitor = ActivityMonitor()

    @IBAction func toggleRobot(sender: UIButton) {
          self.showRobot = !self.showRobot
          self.label = (self.showRobot) ? "Hide" : "Show"
    }
    
    func robotButton() -> UIButton {
        let button : UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        button.setAttributedTitle(NSAttributedString(string: "robot", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor:
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)]), for: UIControl.State.normal)
        button.addTarget(nil, action: #selector(self.toggleRobot), for: UIControl.Event.touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        return button
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        arView.session.pause()
    }
    
    override func viewDidLoad() {
        let exercise = exerciseData[Exercises.jumpingJacks.rawValue]
        self.activityMonitor = ActivityMonitor(exercise: exercise, coachingMode: false)
        print("initiated")
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
        
        self.recordingSession.startRecording()
        speaker.enableSpeech()
        speaker.speak(statement: "In order to start the live coach session, move to the \(exerciseData[1].states[0].name) position")
        
        
        self.startTime = Date().timeIntervalSince1970
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            //self.timer = atimer
            characterAnchor.transform = Transform(matrix: bodyAnchor.transform)
            // ^ or independently set .orientation and .position of characterAnchor
            
            if let character = character, character.parent == nil {
                characterAnchor.addChild(character)
            }
            characterAnchor.isEnabled = showRobot
            
            activityMonitor.updateState(bodyAnchor)
            
            let curTime = Date().timeIntervalSince1970
            self.recordingSession.poll(activityMonitor.currentState)
            if curTime - startTime > 10 {
                self.recordingSession.upload()
                startTime = curTime
            }
            print("reps: ", activityMonitor.repCount)
        }
        
    }
    
    func setupViews() {
        view.addSubview(arView)
        
        let toggleRobotButton = robotButton()
        view.addSubview(toggleRobotButton)
        
        toggleRobotButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 15))
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80))
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30))
        
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }


}
