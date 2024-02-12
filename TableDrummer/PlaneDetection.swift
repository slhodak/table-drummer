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
        
        // add a collider to the plane anchor
        // add a physics body component -- not affected by gravity
        // hyp: the PlaneAnchor is an entity that can have components -- no
        // hyp: the planeAnchor has a size/extent -- yes
        let planeGeometry = MeshResource.generatePlane(width: anchor.geometry.extent.width, depth: anchor.geometry.extent.height)
        let material = SimpleMaterial(color: .blue, roughness: 0.8, isMetallic: false)
        let entity = ModelEntity(mesh: planeGeometry, materials: [material])
        entity.components.set(PhysicsBodyComponent())
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
