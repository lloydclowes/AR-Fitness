import Foundation

struct TimedState : Codable {
    let timestamp : Date
    let augmentedState : ActivityState
    
    init(_ timestamp : Date, _ augmentedState : ActivityState) {
        self.timestamp = timestamp
        self.augmentedState = augmentedState
    }
}

struct TimedStateHistory : Codable {
    var history : [TimedState]
}
