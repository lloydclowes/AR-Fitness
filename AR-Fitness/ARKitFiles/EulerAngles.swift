import Foundation

struct EulerAngles: Codable, Hashable {
    let x : Float?
    let y : Float?
    let z : Float?
    
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
    
    init(x: Float? = nil, y: Float? = nil, z: Float? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func magnitude() -> Float {
        var mag = Float(0)
        if let x1 = x {
            mag += pow(x1, 2)
        }
        if let y1 = y {
            mag += pow(y1, 2)
        }
        if let z1 = z {
            mag += pow(z1, 2)
        }
        return sqrt(mag)
    }
    
    func difference(_ other : EulerAngles, _ tolerances : EulerAngles) -> EulerAngles {
        var dx : Float? = nil
        var dy : Float? = nil
        var dz : Float? = nil
        
        if let x1 = x {
            let tol = tolerances.x!
            let other = other.x!
            dx = x1 + tol - other
            if dx!.sign == tol.sign {
                dx = nil
            }
        }
        if let y1 = y {
            let tol = tolerances.y!
            let other = other.y!
            dy = y1 + tol - other
            if dy!.sign == tol.sign {
                dy = nil
            }
        }
        if let z1 = z {
            let tol = tolerances.z!
            let other = other.z!
            dz = z1 + tol - other
            if dz!.sign == tol.sign {
                dz = nil
            }
        }
        
        return EulerAngles(x: dx, y: dy, z: dz)
    }
}
