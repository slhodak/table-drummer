//
//  ParentHandle.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/19/24.
//

import Foundation
import RealityKit


class ParentHandle {
    static func create(position: SIMD3<Float>, radius: Float, color: RealityFoundation.Material.Color, isMetallic: Bool) -> ModelEntity {
        let entity = ParentHandle.createOrb(radius: radius, color: color, isMetallic: isMetallic)
        entity.components.set(PhysicsBodyComponent(mode: .kinematic))
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.position = position
        entity.name = "ParentHandle_metallic_\(isMetallic)"
        
        return entity
    }
    
    static func createOrb(radius: Float, color: RealityFoundation.Material.Color, isMetallic: Bool) -> ModelEntity {
        let orbMaterial = isMetallic ? DrumsModel.getMetallicMaterial(color: color) : DrumsModel.getMatteMaterial(color: color)
        return ModelEntity(mesh: .generateSphere(radius: radius),
                           materials: [orbMaterial],
                           collisionShape: .generateSphere(radius: radius),
                           mass: 0.0)
    }
}
