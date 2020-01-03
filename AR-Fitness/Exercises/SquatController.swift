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
    let characterOffset: SIMD3<Float> = [0, 0, 0]
    let characterAnchor = AnchorEntity()
    
    var startTime = Double.greatestFiniteMagnitude
    var uploaded = false
    let recordingSession = RecordingSession()
    
    var reachedSquat = false

    var counter = 0
    let speaker = SpeechService.shared
    var rewarded = false
    var timer = Timer()
    
    var lastInstructions = Date().timeIntervalSince1970
    var prevTime = TimeInterval()
    
    var showRobot = true
    
    var activityMonitor = ActivityMonitor()
    
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
        
    let infoButton : UIButton = {
        let button : UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        button.setAttributedTitle(NSAttributedString(string: "See info", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor:
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)]), for: UIControl.State.normal)
        button.addTarget(nil, action: #selector(showInformation), for: UIControl.Event.touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
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
    
    override func viewDidLoad() {
        infoLabel.text = "Reps: \(activityMonitor.repCount)"
        setupViews()
        
        let exercise = exerciseData[Exercises.squat.rawValue]
        self.activityMonitor = ActivityMonitor(start: exercise.startState, states: exercise.states)
        
        speaker.speak(statement: exercise.startMessage)
        lastInstructions = Date().timeIntervalSince1970
        
        self.recordingSession.startRecording()
    }
    
    @IBAction func showInformation(sender: UIButton) {
        let modalViewController = ModalViewController()
        modalViewController.updateInfo(activityMonitor.repCount, timer: counter, exerciseName: "Squats")
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: {})
    }
    
    @IBAction func toggleRobot(sender: UIButton) {
        self.showRobot = !self.showRobot
        // TODO: Fix this
        sender.setTitle(showRobot ? "Hide robot" : "Show robot", for: .normal)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        arView.session.pause()
        speaker.cutOffSpeech()
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
                
//        self.recordingSession.startRecording()
        self.prevTime = Date().timeIntervalSince1970
        self.startTime = Date().timeIntervalSince1970
        self.runTimer()
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
            
            let curTime = Date().timeIntervalSince1970
            let delta = curTime - prevTime
            prevTime = curTime
            activityMonitor.updateState(bodyAnchor, delta)
            if !activityMonitor.started {
                if curTime - lastInstructions > 10 {
                    lastInstructions = curTime
                    speaker.speak(statement: "Please assume the start position.")
                }
                return
            }
            
//          self.recordingSession.poll(activityMonitor.currentState)
//            if curTime - startTime > 10 {
//                print("uploading")
//                self.recordingSession.upload()
//                startTime = curTime
//            }
            
            let reps = activityMonitor.repCount
            self.infoLabel.text = "Reps: \(reps)"
            if reps != 0 && reps.isMultiple(of: 5) && !rewarded {
                rewarded = true
                let randomReward = SpeechSynthesizer.rewards.randomElement()!
                speaker.speak(statement: randomReward)
            }
            if !reps.isMultiple(of: 5) {
                rewarded = false
            }            
        }
    }
    
    @objc func updateTimer() {
        counter += 1
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func setupViews() {
        
        view.addSubview(arView)
        view.addSubview(infoLabel)
        view.addSubview(infoButton)
        view.addSubview(robotButton)
        
        // label constraints (position, size...)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 30))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        self.view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 150))
        
        // button constraints
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: infoButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: infoButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: infoButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 150))
        self.view.addConstraint(NSLayoutConstraint(item: infoButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        
        // toggle robot button constraints
        robotButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 15))
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80))
        self.view.addConstraint(NSLayoutConstraint(item: robotButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30))
        
        
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}






