import UIKit
import RealityKit
import ARKit
import Combine

class RepCountController : ARViewController {
    
    convenience init(exercise : Exercise, instructions : Bool = false, countFirstRep : Bool = false) {
        self.init(nibName: nil, bundle: nil)
        self.exercise = exercise
        var feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>> = [:]
        for targetState in exercise.states {
            feedbackDict[targetState.name] = targetState.feedback
        }
        let gen : FeedbackGenerator
        isInstructionsView = instructions
        if instructions {
            gen = RepCountInstructionsFeedbackGenerator(feedbackDict: feedbackDict)
        } else {
            if (exercise.name == "Lunges" || exercise.name == "Jumping Jacks") {
                gen = BaseFeedbackGenerator(feedbackDict: feedbackDict)
            } else {
                gen = RepCountFeedbackGenerator(feedbackDict: feedbackDict)
            }
        }
        self.activityMonitor = ActivityMonitor(exercise: exercise, feedbackGenerator: gen, countFirstRep: countFirstRep)
    }
    
    override func updateViews() {
        if !isInstructionsView {
            self.scoreLabel.text = "Reps: \(activityMonitor.repCount!)"
        } else {
            self.scoreLabel.removeFromSuperview()
        }
    }
    
    override func handleRewards() {
//        // successCount
//        if activityMonitor.repCount > 0 && activityMonitor.repCount.isMultiple(of: 5) {
//            if !rewarded {
//                rewarded = true
//                speaker.speakRandomReward() {}
//            }
//        } else {
//            rewarded = false
//        }
    }
}






