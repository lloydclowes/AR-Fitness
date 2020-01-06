import Foundation

class PrintingFeedbackGenerator : BaseFeedbackGenerator {
    
    static let shared = PrintingFeedbackGenerator()
    
    override func started() {
        print("started")
    }
    
    override func advanced() {
        print("advanced")
    }
    
    override func completeSuccess() {
        print("complete - success")
    }
    
    override func completeFail(tooFast: Bool = false, missedStates: Dictionary<String, Set<String>> = [:], shortStates: [String] = []) {
        print("complete - fail")
    }
    
    override func jumped(to: Int) {
        print("jumped to \(to)")
    }
    
    override func retry() {
        print("retry")
    }
    
    override func tooFast() {
        print("too fast")
    }
    
    override func noState(difference: JointAngles) {
        print("no state")
    }
    
    override func expired() {
        print("expired")
    }
    
}
