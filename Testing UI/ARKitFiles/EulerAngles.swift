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
    
    init(x: Float? = nil, y: Float? = nil, z: Float? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
}
