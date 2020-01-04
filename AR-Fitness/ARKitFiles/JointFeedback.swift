import Foundation

struct Feedback : Hashable, Codable {
    let decrease : String
    let increase : String
}

struct JointFeedback : Hashable, Codable {
    let xFeedback : Feedback?
    let yFeedback : Feedback?
    let zFeedback : Feedback?
}

