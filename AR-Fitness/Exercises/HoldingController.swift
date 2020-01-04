import UIKit
import RealityKit
import ARKit
import Combine

class HoldingController : ARViewController {

    private var countedDown = false
    private var halfReward = false
    private var fiveReward = false
    private var completed = false
    
    override func updateViews() {
        scoreLabel.text = "Timer: \(Int(round(activityMonitor.remainingDuration)))"
    }
    
    override func handleRewards() {
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





