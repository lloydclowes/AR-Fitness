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
    
    func difference(_ other : EulerAngles) -> EulerAngles {
        return EulerAngles(x: (x ?? 0) - (other.x ?? 0), y: (y ?? 0) - (other.y ?? 0), z: (z ?? 0) - (other.z ?? 0))
    }
}
