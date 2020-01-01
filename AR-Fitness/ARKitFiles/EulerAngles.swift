//
//  EulerAngles.swift
//  AR-Sports
//
//  Created by Brandon Forbes on 27/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

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
            dx = x1 - (other.x ?? 0) + (tolerances.x ?? 0)
            if dx! >= 0 {
                dx = nil
            }
        }
        if let y1 = y {
            dy = y1 - (other.y ?? 0) + (tolerances.y ?? 0)
            if dy! >= 0 {
                dy = nil
            }
        }
        if let z1 = z {
            dz = z1 - (other.z ?? 0) + (tolerances.z ?? 0)
            if dz! >= 0 {
                dz = nil
            }
        }
        
        return EulerAngles(x: dx, y: dy, z: dz)
    }
}
