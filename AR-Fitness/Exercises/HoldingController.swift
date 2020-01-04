import UIKit
import RealityKit
import ARKit
import Combine

class HoldingController: UIViewController, ARSessionDelegate {

    var arView = ARView(frame: .zero)
    
    var exercise : Exercise!
    var activityMonitor : ActivityMonitor!

    var recordHistory = false
    var uploaded = false
    let recordingSession = RecordingSession()
    
    let speaker = SpeechService.shared
    var started = false
    var rewarded = false
    
    var startTime = Double.greatestFiniteMagnitude
    var lastInstructions = TimeInterval()
    var prevTime = TimeInterval()
    
    var showRobot = true
    var character: BodyTrackedEntity?
    let characterAnchor = AnchorEntity()
    
    var countedDown = false
    var halfReward = false
    var fiveReward = false
    var completed = false
    
    let timerLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = NSTextAlignment.center
        label.adjustsFontSizeToFitWidth = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        return label
    }()
    
    let toggleRobotButton : UIButton = {
        let button : UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        button.setAttributedTitle(NSAttributedString(string: "Toggle Robot", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor:
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)]), for: .normal)
        button.addTarget(nil, action: #selector(toggleRobot), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        return button
    }()
    
    convenience init(exercise : Exercise, liveFeedback : Bool, countFirstRep : Bool = false) {
        self.init(nibName: nil, bundle: nil)
        self.exercise = exercise
        self.activityMonitor = ActivityMonitor(exercise: exercise, liveFeedback: liveFeedback, countFirstRep: countFirstRep)
    }
    
    deinit {
        print("DEINIT HOLDING VIEW CONTROLLER")
    }
    
    @IBAction func toggleRobot(sender: UIButton) {
        showRobot = !showRobot
        sender.setTitle(showRobot ? "Hide" : "Show", for: .normal) // TODO: Fix this
    }
    
    override func viewDidLoad() {
        setupViews()
        timerLabel.text = "Timer: \(Int(round(activityMonitor.remainingDuration)))"
//        speaker.speak(text: exercise.startMessage)
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
        
        if recordHistory {
            self.recordingSession.startRecording()
        }
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
                if curTime - lastInstructions > 10 {
                    lastInstructions = curTime
                    speaker.speak(text: "Please assume the start position.")
                }
                return
            }
            
            if recordHistory {
                self.recordingSession.poll(activityMonitor.currentState)
                if curTime - startTime > 10 {
                    print("uploading")
                    self.recordingSession.upload()
                    startTime = curTime
                }
            }
            
            if !started {
                speaker.speak(text: "Good! Now hold that posture for 20 seconds")
                startTime = Date().timeIntervalSince1970
                started = true
            }
            
            timerLabel.text = "Timer: \(Int(round(activityMonitor.remainingDuration)))"
            if !halfReward && round(activityMonitor.remainingDuration) <= 10 {
                halfReward = true
                speaker.speak(text: "Half way there!")
            } else if !fiveReward && round(activityMonitor.remainingDuration) <= 5 {
                fiveReward = true
                speaker.speak(text: "Only five more seconds!")
            } else if !completed && round(activityMonitor.remainingDuration) <= 0 {
                speaker.speak(text: "Well done! You've completed the challenge")
                completed = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        arView.session.pause()
        speaker.cutOffSpeech()
    }
    
    private func setupViews() {
        view.addSubview(arView)
        view.addSubview(timerLabel)
        view.addSubview(toggleRobotButton)
        
        // label constraints (position, size...)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 30))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 150))
        
        toggleRobotButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 15))
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30))
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80))
        self.view.addConstraint(NSLayoutConstraint(item: toggleRobotButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30))
        
        // arView constraints
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        arView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}





