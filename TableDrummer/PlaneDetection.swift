//
//  PlaneDetection.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/12/24.
//

import Foundation
import ARKit
import RealityKit


@MainActor var planeAnchors: [UUID: PlaneAnchor] = [:]
@MainActor var entityMap: [UUID: Entity] = [:]

@MainActor
func updatePlane(_ anchor: PlaneAnchor) {
    if planeAnchors[anchor.id] == nil {
        // Add a new entity to represent this plane.
        let entity = ModelEntity(mesh: .generateText(anchor.classification.description))
        entityMap[anchor.id] = entity
        root.addChild(entity)
    }
    
    entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
}

@MainActor
func removePlane(_ anchor: PlaneAnchor) {
    entityMap[anchor.id]?.removeFromParent()
    entityMap.removeValue(forKey: anchor.id)
    planeAnchors.removeValue(forKey: anchor.id)
}
