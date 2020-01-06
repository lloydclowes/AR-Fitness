import Foundation

protocol FeedbackGenerator {
    
    func started(finished: () -> Void)
    func advanced(finished: () -> Void)
    func completeSuccess(finished: () -> Void)
    func completeFail(tooFast: Bool, missedStates: Dictionary<String, Set<String>>, shortStates: [String], finished: () -> Void)
    func jumped(to : Int, finished: () -> Void)
    func retry(finished: () -> Void)
    func tooFast(finished: () -> Void)
    func noState(targetName : String, difference: Dictionary<String, EulerAngles>, finished: () -> Void)
    func expired(finished: () -> Void)
    
}

class BaseFeedbackGenerator : FeedbackGenerator {
        
    let speaker = SpeechService.shared
    
    let feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>>
    
    let tooFastRegularity : TimeInterval
    let noStateRegularity : TimeInterval
    
    var lastTooFast = TimeInterval()
    var lastNoState = TimeInterval()
    
    internal var curTime : TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    init(feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>>,
         tooFastRegularity : TimeInterval = 1,
         noStateRegularity : TimeInterval = 10) {
        self.feedbackDict = feedbackDict
        self.tooFastRegularity = tooFastRegularity
        self.noStateRegularity = noStateRegularity
    }
    
    func started(finished: () -> Void) {}
    
    func advanced(finished: () -> Void) {}
    
    func completeSuccess(finished: () -> Void) {}
    
    func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: () -> Void) {}
    
    func jumped(to: Int, finished: () -> Void) {}
    
    func retry(finished: () -> Void) {}
    
    func tooFast(finished: () -> Void) {}
    
    func noState(targetName : String, difference: Dictionary<String, EulerAngles>, finished: () -> Void) {}
    
    func expired(finished: () -> Void) {}
}
