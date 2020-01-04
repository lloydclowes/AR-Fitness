import Foundation
import RealityKit
import ARKit

extension ARBodyAnchor {
    // Returns the angle of rotation about the X, Y and Z axes respectively of a joint relative to its parent
    func getLocalJointAngleXYZ(_ name: String) -> EulerAngles {
        guard let ind : Int = ARSkeletonDefinition.defaultBody3D.jointNames.firstIndex(of: name) else {
            return EulerAngles()
        }
        return getRotationXYZ(matrix: self.skeleton.jointLocalTransforms[ind])
    }
    
    // Returns the angle of rotation about the X, Y and Z axes respectively of a joint relative to the hips
    func getModelJointAngleXYZ(_ name: String) -> EulerAngles {
        guard let ind : Int = ARSkeletonDefinition.defaultBody3D.jointNames.firstIndex(of: name) else {
            return EulerAngles()
        }
        return getRotationXYZ(matrix: self.skeleton.jointModelTransforms[ind])
    }
    
    func getModelJointPosXYZ(_ name: String) -> simd_float3 {
        guard let ind : Int = ARSkeletonDefinition.defaultBody3D.jointNames.firstIndex(of: name) else {
            return simd_float3()
        }
        return Transform(matrix: self.skeleton.jointModelTransforms[ind]).translation
    }
    
    func getBodyJointAngles(_ joints : [String]) -> JointAngles {
        var angles = JointAngles()
        for joint in joints {
            angles[joint] = getLocalJointAngleXYZ(joint)
        }
        return angles
    }
}
