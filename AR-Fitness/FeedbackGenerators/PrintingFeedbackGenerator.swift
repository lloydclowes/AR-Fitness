import Foundation

class PrintingFeedbackGenerator : BaseFeedbackGenerator {
    
    static let shared = PrintingFeedbackGenerator()
    
    override func started(finished: () -> Void) {
        print("started")
        finished()
    }
    
    override func advanced(finished: () -> Void) {
        print("advanced")
        finished()
    }
    
    override func completeSuccess(finished: () -> Void) {
        print("complete - success")
        finished()
    }
    
    override func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = [], finished: () -> Void) {
        print("complete - fail")
        finished()
    }
    
    override func jumped(to: Int, finished: () -> Void) {
        print("jumped to \(to)")
        finished()
    }
    
    override func retry(finished: () -> Void) {
        print("retry")
        finished()
    }
    
    override func tooFast(finished: () -> Void) {
        print("too fast")
        finished()
    }
    
    override func noState(difference: JointAngles, finished: () -> Void) {
        print("no state")
        finished()
    }
    
    override func expired(finished: () -> Void) {
        print("expired")
        finished()
    }
    
}
