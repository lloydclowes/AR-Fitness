import UIKit
import RealityKit
import ARKit
import Combine

class RepCountController : ARViewController {
        
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






