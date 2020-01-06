import Foundation

protocol FeedbackGenerator {
    
    func started()
    func advanced()
    func completeSuccess()
    func completeFail(tooFast: Bool, missedStates: Dictionary<String, Set<String>>, shortStates: [String])
    func jumped(to : Int)
    func retry()
    func tooFast()
    func noState(difference: JointAngles)
    func expired()
    
}

class BaseFeedbackGenerator : FeedbackGenerator {
        
    let speaker = SpeechService.shared
    
    func started() {}
    
    func advanced() {}
    
    func completeSuccess() {}
    
    func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = []) {}
    
    func jumped(to: Int) {}
    
    func retry() {}
    
    func tooFast() {}
    
    func noState(difference: JointAngles) {}
    
    func expired() {}
}
