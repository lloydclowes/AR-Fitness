import UIKit
import RealityKit
import ARKit
import Combine

class RepCountController : ARViewController {
    
    override func updateViews() {
        self.scoreLabel.text = "Reps: \(activityMonitor.repCount)"
    }
    
    override func handleRewards() {
        if activityMonitor.repCount % 5 == 1 {
            if !rewarded {
                rewarded = true
                speaker.speakRandomReward()
            }
        } else {
            rewarded = false
        }
    }
}






