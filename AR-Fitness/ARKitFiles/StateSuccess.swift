import Foundation

struct StateSuccess {
    var duration : Double = 0.0
    var jointFailures : Set<String> = []
    
    init(joints : [String]) {
        for joint in joints {
            jointFailures.insert(joint)
        }
    }
}
