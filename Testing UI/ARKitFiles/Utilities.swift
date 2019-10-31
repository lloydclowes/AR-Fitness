/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions that support the sample app.
*/

import Foundation
import RealityKit
import ARKit

typealias JointAngles = Dictionary<String, EulerAngles>

let radToDeg = 180 / Float.pi

extension MeshResource {
    /**
     Generate three axes of a coordinate system with x axis = red, y axis = green and z axis = blue
     - parameters:
     - axisLength: Length of the axes in m
     - thickness: Thickness of the axes as a percentage of their length
     */
    static func generateCoordinateSystemAxes(length: Float = 0.1, thickness: Float = 2.0) -> Entity {
        let thicknessInM = (length / 100) * thickness
        let cornerRadius = thickness / 2.0
        let offset = length / 2.0
        
        let xAxisBox = MeshResource.generateBox(size: [length, thicknessInM, thicknessInM], cornerRadius: cornerRadius)
        let yAxisBox = MeshResource.generateBox(size: [thicknessInM, length, thicknessInM], cornerRadius: cornerRadius)
        let zAxisBox = MeshResource.generateBox(size: [thicknessInM, thicknessInM, length], cornerRadius: cornerRadius)
    
        let xAxis = ModelEntity(mesh: xAxisBox, materials: [UnlitMaterial(color: .red)])
        let yAxis = ModelEntity(mesh: yAxisBox, materials: [UnlitMaterial(color: .green)])
        let zAxis = ModelEntity(mesh: zAxisBox, materials: [UnlitMaterial(color: .blue)])
        
        xAxis.position = [offset, 0, 0]
        yAxis.position = [0, offset, 0]
        zAxis.position = [0, 0, offset]
        
        let axes = Entity()
        axes.addChild(xAxis)
        axes.addChild(yAxis)
        axes.addChild(zAxis)
        return axes
    }
}

// Converts a column major simd_float4x4 into its 3 rotations about the X, Y, Z axes respectively.
func getRotationXYZ(_ transform: simd_float4x4) -> EulerAngles {
    let rows = transform.transpose.columns
    let angleX = radToDeg * atan(rows.2[1] / rows.2[2])
    let angleY = radToDeg * atan(-rows.2[0] / sqrt(pow(rows.2[1], 2) + pow(rows.2[2], 2)))
    let angleZ = radToDeg * atan(rows.1[0] / rows.0[0])
    return EulerAngles(x: angleX, y: angleY, z: angleZ)
}
