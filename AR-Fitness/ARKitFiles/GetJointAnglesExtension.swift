//
//  GetJointAnglesExtension.swift
//  AR-Sports
//
//  Created by Brandon Forbes on 21/10/2019.
//  Copyright © 2019 LV8. All rights reserved.
//

import Foundation
import RealityKit
import ARKit

extension ARBodyAnchor {
    // Returns the angle of rotation about the X, Y and Z axes respectively of a joint relative to its parent
    func getLocalJointAngleXYZ(_ name: String) -> EulerAngles {
        guard let ind : Int = ARSkeletonDefinition.defaultBody3D.jointNames.firstIndex(of: name) else {
            return EulerAngles()
        }
        return getRotationXYZ(self.skeleton.jointLocalTransforms[ind])
    }
    
    // Returns the angle of rotation about the X, Y and Z axes respectively of a joint relative to the hips
    func getModelJointAngleXYZ(_ name: String) -> EulerAngles {
        guard let ind : Int = ARSkeletonDefinition.defaultBody3D.jointNames.firstIndex(of: name) else {
            return EulerAngles()
        }
        return getRotationXYZ(self.skeleton.jointModelTransforms[ind])
    }
    
    func getModelJointPosXYZ(_ name: String) -> simd_float3 {
        guard let ind : Int = ARSkeletonDefinition.defaultBody3D.jointNames.firstIndex(of: name) else {
            return simd_float3()
        }
        return Transform(matrix: self.skeleton.jointModelTransforms[ind]).translation
    }
    
    func getBodyState(_ joints : [String]) -> ActivityState {
        var angles = JointAngles()
        for joint in joints {
            angles[joint] = getLocalJointAngleXYZ(joint)
        }
        return ActivityState(angles)
    }
}
