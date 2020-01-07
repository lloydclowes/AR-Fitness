import Foundation

protocol FeedbackGenerator {
    
    func started(finished: @escaping () -> Void)
    func advanced(finished: @escaping () -> Void)
    func completeSuccess(finished: @escaping () -> Void)
    func completeFail(tooFast: Bool, missedStates: Dictionary<String, Set<String>>, shortStates: [String], finished: @escaping () -> Void)
    func jumped(to : Int, finished: @escaping () -> Void)
    func resume(finished: @escaping () -> Void)
    func tooFast(finished: @escaping () -> Void)
    func stay(finished : @escaping () -> Void)
    func next(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void)
    func noState(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void)
    func expired(finished: @escaping () -> Void)
    
}

class BaseFeedbackGenerator : FeedbackGenerator {
        
    let speaker = SpeechService.shared
    
    let feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>>
    
    let tooFastRegularity : TimeInterval
    let stayRegularity : TimeInterval
    let nextPromptRegularity : TimeInterval
    let expiredRegularity : TimeInterval
    
    var lastTooFast = TimeInterval()
    var lastStay = TimeInterval()
    var lastNextPrompt = TimeInterval()
    var lastExpired = TimeInterval()

    internal var curTime : TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    init(feedbackDict : Dictionary<String, Dictionary<String, JointFeedback>>,
         tooFastRegularity : TimeInterval = 1,
         stayRegularity : TimeInterval = 5,
         nextPromptRegularity : TimeInterval = 5,
         expiredRegularity : TimeInterval = 13) {
        self.feedbackDict = feedbackDict
        self.tooFastRegularity = tooFastRegularity
        self.stayRegularity = stayRegularity
        self.nextPromptRegularity = nextPromptRegularity
        self.expiredRegularity = expiredRegularity
    }
    
    func started(finished: @escaping () -> Void) {
        finished()
    }
    
    func advanced(finished: @escaping () -> Void)  {
           finished()
    }
    
    func completeSuccess(finished: @escaping () -> Void) {
           finished()
    }
    
    func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: @escaping () -> Void) {
           finished()
    }
    
    func jumped(to: Int, finished: @escaping () -> Void)  {
           finished()
    }
    
    func resume(finished: @escaping () -> Void)  {
           finished()
    }
    
    func tooFast(finished: @escaping () -> Void)  {
           finished()
    }
    
    func stay(finished : @escaping () -> Void)  {
           finished()
    }
    
    func next(targetName : String, difference : Dictionary<String, EulerAngles>, finished : @escaping () -> Void)  {
           finished()
    }

    func noState(targetName : String, difference : Dictionary<String, EulerAngles>, finished: @escaping () -> Void)  {
           finished()
    }
    
    func expired(finished: @escaping () -> Void)  {
           finished()
   }
}
