import Foundation

struct AxisFeedback : Hashable, Codable {
    let action : [String]
    let side : String
    let name : String
}

struct JointFeedback : Hashable, Codable {
    let x : AxisFeedback?
    let y : AxisFeedback?
    let z : AxisFeedback?
}
