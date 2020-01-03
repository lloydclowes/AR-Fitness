//
//  SlowSquatController.swift
//  AR-Fitness
//
//  Created by Blanca Tebar on 01/12/2019.
//  Copyright © 2019 SE Project Group 8. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class SlowSquatController: UIViewController, ARSessionDelegate {

    var arView = ARView(frame: .zero)
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0]
    let characterAnchor = AnchorEntity()

    var uploaded = false
    let recordingSession = RecordingSession()

    var initial = true
    var reachedSquat = false
    var timer = Timer()
    var counter = 0
    let speaker = SpeechService.shared
    var rewarded = false

    var showRobot = false

    var activityMonitor = ActivityMonitor()

    let robotButton : UIButton = {
        let button : UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        button.setAttributedTitle(NSAttributedString(string: "Toggle robot", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor:
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)]), for: .normal)
        button.addTarget(nil, action: #selector(toggleRobot), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        return button
    }()
    override func viewDidDisappear(_ animated: Bool) {
        arView.session.pause()
    }
    
    override func viewDidLoad() {
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
        configuration.environmentTexturing = .none
        
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
        
        let exercise = exerciseData[Exercises.squat.rawValue]
        self.activityMonitor = ActivityMonitor(exercise: exercise, coachingMode: true)
        
        self.recordingSession.startRecording()
        speaker.speak(statement: exercise.startMessage)
    }
    
    @IBAction func toggleRobot(sender: UIButton) {
        self.showRobot = !self.showRobot
        // TODO: Fix this
        sender.setTitle(showRobot ? "Hide robot" : "Show robot", for: .normal)
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

//            self.recordingSession.poll(activityMonitor.currentState, ActivityState())
        }
    }
    
    func setupViews() {
        view.addSubview(arView)
        view.addSubview(robotButton)
        
        // toggle robot button constraints
        robotButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 15))
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100))
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30))
        
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
