import UIKit
import RealityKit
import ARKit
import Combine

class HoldingController : ARViewController {

    private var halfReward = false
    private var fiveReward = false
    private var completed = false
    
    convenience init(exercise : Exercise, instructions : Bool = false, countFirstRep : Bool = false) {
        self.init(nibName: nil, bundle: nil)
        self.exercise = exercise
        var feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>> = [:]
        for targetState in exercise.states {
            print(targetState.name)
            print(targetState.feedback)
            feedbackDict[targetState.name] = targetState.feedback
        }
        
        let gen : FeedbackGenerator
        if instructions {
            gen = HoldingInstructionsFeedbackGenerator(feedbackDict: feedbackDict)
        } else {
            gen = HoldingFeedbackGenerator(feedbackDict: feedbackDict)
        }
        
        self.activityMonitor = ActivityMonitor(exercise: exercise, feedbackGenerator: gen, countFirstRep: countFirstRep)
    }
    
    override func updateViews() {
        scoreLabel.text = "Timer: \(Int(ceil(activityMonitor.remainingDuration)))"
    }
    
    override func handleRewards() {
        if !halfReward && ceil(activityMonitor.remainingDuration) <= activityMonitor.fullDuration / 2 {
            halfReward = true
            speaker.speak(text: "Half way there!")
        } else if !completed && ceil(activityMonitor.remainingDuration) <= 0 {
            speaker.speak(text: "Well done! You've completed the challenge")
            completed = true
        }
    }
}





