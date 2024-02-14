//
//  PlaneDetection.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/12/24.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit


class PlaneDetection: ObservableObject {
    @State var planeAnchors: [UUID: PlaneAnchor] = [:]
    @State var entityMap: [UUID: Entity] = [:]
    let arSession = ARKitSession()
    let planeData = PlaneDetectionProvider(alignments: [.horizontal])
    
    func detectPlanesAndAdd(to entity: Entity) {
        Task {
            try await arSession.run([planeData])
            for await update in planeData.anchorUpdates {
                switch update .event {
                case .added:
                    await addPlane(anchor: update.anchor, to: entity)
                case .updated, .removed:
                    break
                }
            }
        }
    }
    
    func updatePlanes() {
        Task {
            try await arSession.run([planeData])
            for await update in planeData.anchorUpdates {
                switch update .event {
                case .added:
                    break
                case .updated:
                    await updatePlane(update.anchor)
                case .removed:
                    await removePlane(update.anchor)
                }
            }
        }
    }
    
    @MainActor
    func addPlane(anchor: PlaneAnchor, to entity: Entity) {
        // Add a new entity to represent this plane.
        let width = anchor.geometry.extent.width
        let height = anchor.geometry.extent.height
        let depth: Float = 0.05
        let planeGeometry = MeshResource.generateBox(width: width, height: height, depth: depth)
        let material = SimpleMaterial(color: .blue, roughness: 0.8, isMetallic: false)
        let planeEntity = ModelEntity(mesh: planeGeometry, materials: [material])
        // Should height and depth be swapped?
        let collisionShape = ShapeResource.generateBox(width: width, height: height, depth: depth)
        
        planeEntity.components.set(PhysicsBodyComponent())
        planeEntity.components.set(CollisionComponent(shapes: [collisionShape]))
        entityMap[anchor.id] = entity
        entity.addChild(planeEntity)
    }
    
    @MainActor
    func updatePlane(_ anchor: PlaneAnchor) {
        entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }
    
    @MainActor
    func removePlane(_ anchor: PlaneAnchor) {
        entityMap[anchor.id]?.removeFromParent()
        entityMap.removeValue(forKey: anchor.id)
        planeAnchors.removeValue(forKey: anchor.id)
    }
}
