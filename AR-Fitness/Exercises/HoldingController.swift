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
        scoreLabel.text = "Timer: \(Int(ceil(activityMonitor.remainingDuration)))"
    }
    
    override func handleRewards() {
        if !halfReward && ceil(activityMonitor.remainingDuration) <= activityMonitor.fullDuration / 2 {
            halfReward = true
            speaker.speak(text: "Half way there!")
        } else if !fiveReward && ceil(activityMonitor.remainingDuration) <= 5 {
            fiveReward = true
            speaker.speak(text: "Only five more seconds!")
        } else if !completed && ceil(activityMonitor.remainingDuration) <= 0 {
            speaker.speak(text: "Well done! You've completed the challenge")
            completed = true
        }
    }
}





