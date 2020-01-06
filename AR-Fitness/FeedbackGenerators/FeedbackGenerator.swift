import Foundation

protocol FeedbackGenerator {
    
    func started(finished: () -> Void)
    func advanced(finished: () -> Void)
    func completeSuccess(finished: () -> Void)
    func completeFail(tooFast: Bool, missedStates: Dictionary<String, Set<String>>, shortStates: [String], finished: () -> Void)
    func jumped(to : Int, finished: () -> Void)
    func retry(finished: () -> Void)
    func tooFast(finished: () -> Void)
    func noState(difference: JointAngles, finished: () -> Void)
    func expired(finished: () -> Void)
    
}

class BaseFeedbackGenerator : FeedbackGenerator {
        
    let speaker = SpeechService.shared
    
    func started(finished: () -> Void) {}
    
    func advanced(finished: () -> Void) {}
    
    func completeSuccess(finished: () -> Void) {}
    
    func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: () -> Void) {}
    
    func jumped(to: Int, finished: () -> Void) {}
    
    func retry(finished: () -> Void) {}
    
    func tooFast(finished: () -> Void) {}
    
    func noState(difference: JointAngles, finished: () -> Void) {}
    
    func expired(finished: () -> Void) {}
}
