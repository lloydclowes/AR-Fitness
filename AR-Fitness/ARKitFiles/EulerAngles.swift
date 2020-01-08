import Foundation

enum ToleranceType : String, Hashable, Codable {
    case greaterThan = ">"
    case lessThan = "<"
    case around = "~"
}

struct Tolerance : Hashable, Codable {
    let tol : Float
    let type : ToleranceType
    
    public var description : String {
        return "\(type)\(tol)"
    }
    
    init(_ type : ToleranceType, _ tol : Float) {
        self.type = type
        self.tol = tol
    }
}

struct EulerAngle : Hashable, Codable {
    let val : Float
    let tol : Tolerance?
    
    public var description : String {
        guard let tolerance = tol else { return val.description }
        if tolerance.tol > 0 {
            return "\(tolerance.type)\(val)+\(tolerance.tol)"
        } else {
            return "\(tolerance.type)\(val)\(tolerance.tol)"
        }
    }
    
    init(_ val : Float, tol : Tolerance? = nil) {
        self.val = val
        self.tol = tol
    }
    
    func difference(_ other : EulerAngle) -> EulerAngle? {
        guard let tolerance = tol else {
            return EulerAngle(self.val - other.val)
        }
        
        switch tolerance.type {
        case .greaterThan:
            if val + tolerance.tol < other.val { return nil }
            return EulerAngle(val - other.val)
        case .lessThan:
            if val + tolerance.tol > other.val { return nil }
            return EulerAngle(val - other.val)
        case .around:
            if abs(val - other.val) < abs(tolerance.tol) { return nil }
            let top = val + tolerance.tol - other.val
            let bottom = val - tolerance.tol - other.val
            return abs(top) <= abs(bottom) ? EulerAngle(top) : EulerAngle(bottom)
        }
    }
}

struct EulerAngles: Codable, Hashable {
    let x : EulerAngle?
    let y : EulerAngle?
    let z : EulerAngle?
    
    public var description: String {
        var str = "("
        if let xstr = x {
            str += xstr.description + ","
        }
        if let ystr = y {
            str += ystr.description + ","
        }
        if let zstr = z {
            str += zstr.description + ","
        }
        return str + ")"
    }
    
    init() {
        self.x = nil
        self.y = nil
        self.z = nil
    }
    
    init(x: Float? = nil, y: Float? = nil, z: Float? = nil) {
        self.x = x != nil ? EulerAngle(x!) : nil
        self.y = y != nil ? EulerAngle(y!) : nil
        self.z = z != nil ? EulerAngle(z!) : nil
    }
    
    init(x: EulerAngle? = nil, y: EulerAngle? = nil, z: EulerAngle? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func magnitude() -> Float {
        var mag = Float(0)
        if let x1 = x {
            mag += pow(x1.val, 2)
        }
        if let y1 = y {
            mag += pow(y1.val, 2)
        }
        if let z1 = z {
            mag += pow(z1.val, 2)
        }
        return sqrt(mag)
    }
    
    func difference(_ other : EulerAngles) -> EulerAngles {
        var dx : EulerAngle? = nil
        var dy : EulerAngle? = nil
        var dz : EulerAngle? = nil
        
        if let x1 = x {
            dx = x1.difference(other.x!)
        }
        
        if let y1 = y {
            dy = y1.difference(other.y!)
        }
        
        if let z1 = z {
            dz = z1.difference(other.z!)
        }
        
        return EulerAngles(x: dx, y: dy, z: dz)
    }
    
//    func difference(_ other : EulerAngles, _ tolerances : EulerAngles) -> EulerAngles {
//        var dx : Float? = nil
//        var dy : Float? = nil
//        var dz : Float? = nil
//        
//        if let x1 = x?.val {
//            let tol = tolerances.x!
//            let other = other.x!
//            dx = x1 + tol - other
//            if dx!.sign == tol.sign {
//                dx = nil
//            }
//        }
//        if let y1 = y {
//            let tol = tolerances.y!
//            let other = other.y!
//            dy = y1 + tol - other
//            if dy!.sign == tol.sign {
//                dy = nil
//            }
//        }
//        if let z1 = z {
//            let tol = tolerances.z!
//            let other = other.z!
//            dz = z1 + tol - other
//            if dz!.sign == tol.sign {
//                dz = nil
//            }
//        }
//        
//        return EulerAngles(x: dx, y: dy, z: dz)
//    }
}
