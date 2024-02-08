//
//  DrumPads.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import Foundation
import RealityKit


class DrumPads {
    static func createPads(numPads: Int, addTo anchor: AnchorEntity? = nil) -> [ModelEntity] {
        let planeMesh = MeshResource.generatePlane(width: 0.1, depth: 0.1, cornerRadius: 0.02)
        let material = SimpleMaterial(color: .blue, roughness: 0.6, isMetallic: false)
        var padEntities: [ModelEntity] = []
        let padSpacing: Float = 0.2
        // subtract 1 from number of pads to get number of spaces between pads
        let halfPadsWidth: Float = Float(numPads-1) * padSpacing / 2.0
        let leftmostPadX: Float = -1 * halfPadsWidth
        
        for i in 0..<numPads {
            let padEntity = ModelEntity(mesh: planeMesh, materials: [material])
            let padOffset = Float(i) * padSpacing
            padEntity.position = [leftmostPadX + padOffset, 1.25, -0.6]
            padEntity.name = "drumpad\(i)"
            if let anchor = anchor {
                anchor.addChild(padEntity)
            }
            padEntities.append(padEntity)
        }
        
        return padEntities
    }
}
