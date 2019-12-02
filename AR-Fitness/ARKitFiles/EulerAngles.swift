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
    
    func difference(_ other : EulerAngles, _ tolerances : EulerAngles) -> EulerAngles {
        
        var newX : Float? = nil
        var newY : Float? = nil
        var newZ : Float? = nil
        
        if let x1 = x, let xtol = tolerances.x, xtol.sign != x1.sign && abs(x1) >= abs(xtol) {
            newX = x1 - (other.x ?? 0)
        }
        
        if let y1 = y, let ytol = tolerances.y, ytol.sign != y1.sign && abs(y1) >= abs(ytol){
            newY = y1 - (other.y ?? 0)
        }
        
        if let z1 = z, let ztol = tolerances.z, ztol.sign != z1.sign && abs(z1) >= abs(ztol) {
            newZ = z1 - (other.z ?? 0)
        }
        
        return EulerAngles(x: newX, y: newY, z: newZ)
    }
}
