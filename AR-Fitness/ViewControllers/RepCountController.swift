import UIKit
import RealityKit
import ARKit
import Combine

class RepCountController : ARViewController {
        
    convenience init(exercise : Exercise, liveFeedback : Bool, countFirstRep : Bool = false) {
        self.init(nibName: nil, bundle: nil)
        self.exercise = exercise
        var feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>> = [:]
        for targetState in exercise.states {
            feedbackDict[targetState.name] = targetState.feedback
        }
        let gen = RepCountFeedbackGenerator(feedbackDict: feedbackDict)
        self.activityMonitor = ActivityMonitor(exercise: exercise, feedbackGenerator: gen, liveFeedback: liveFeedback, countFirstRep: countFirstRep)
    }
    
    override func updateViews() {
        self.scoreLabel.text = "Reps: \(activityMonitor.repCount!)"
    }
    
    override func handleRewards() {
        // successCount
        if activityMonitor.repCount > 0 && activityMonitor.repCount.isMultiple(of: 5) {
            if !rewarded {
                rewarded = true
                speaker.speakRandomReward()
            }
        } else {
            rewarded = false
        }
    }
}






