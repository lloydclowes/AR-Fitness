import Foundation

typealias StateHistory = Dictionary<String, JointHistory>

struct JointHistory {
    var xs = [Float?]()
    var ys = [Float?]()
    var zs = [Float?]()
        
    func count() -> Int {
        return self.xs.count
    }
    
    mutating func append(jointAngles: EulerAngles) {
        if let x = jointAngles.x?.val {
            self.xs.append(x)
        }
        if let y = jointAngles.y?.val {
            self.ys.append(y)
        }
        if let z = jointAngles.z?.val {
            self.zs.append(z)
        }
    }
    
    mutating func remove(at: Int) {
        self.xs.remove(at: at)
        self.ys.remove(at: at)
        self.zs.remove(at: at)
    }
}
