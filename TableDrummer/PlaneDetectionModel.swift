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


class PlaneDetectionModel: ObservableObject {
    @State var planeAnchors: [UUID: PlaneAnchor] = [:]
    @State var entityMap: [UUID: Entity] = [:]
    let arSession = ARKitSession()
    let planeData = PlaneDetectionProvider(alignments: [.horizontal])
    var authorized: Bool = false
    
    func authorize() async {
        print("WorldTrackingProvider.isSupported: \(WorldTrackingProvider.isSupported)")
        print("PlaneDetectionProvider.isSupported: \(PlaneDetectionProvider.isSupported)")
        print("SceneReconstructionProvider.isSupported: \(SceneReconstructionProvider.isSupported)")
        print("HandTrackingProvider.isSupported: \(HandTrackingProvider.isSupported)")
        
        let authorizationResult = await arSession.requestAuthorization(for: [.worldSensing])
        
        for (authorizationType, authorizationStatus) in authorizationResult {
            print("Authorization status for \(authorizationType): \(authorizationStatus)")
            switch authorizationStatus {
            case .allowed:
                break
            case .denied, .notDetermined:
                authorized = false
            @unknown default:
                break
            }
        }
        
        authorized = true
    }
    
    func detectPlanes() async {
        do {
            try await arSession.run([planeData])
            for await update in planeData.anchorUpdates {
                switch update .event {
                case .added:
                    await addPlane(anchor: update.anchor)
                case .updated, .removed:
                    break
                }
            }
        } catch {
            print("Error detecting planes")
            print(error.localizedDescription)
        }
    }
    
    func updatePlanes() async {
        print("Updating planes")
        do {
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
        } catch {
            print("Error updating detected planes")
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func addPlane(anchor: PlaneAnchor) {
        // Add a new entity to represent this plane.
        let width = anchor.geometry.extent.width
        let height = anchor.geometry.extent.height
        let depth: Float = 0.01
        let planeGeometry = MeshResource.generateBox(width: width, height: height, depth: depth)
        let material = SimpleMaterial(color: .blue, roughness: 0.8, isMetallic: false)
        let planeEntity = ModelEntity(mesh: planeGeometry, materials: [material])
        // Should height and depth be swapped?
        let collisionShape = ShapeResource.generateBox(width: width, height: height, depth: depth)
        
        let radians = 90 * (Float.pi / 180)
        planeEntity.orientation = simd_quatf(angle: radians, axis: [1, 0, 0])
        planeEntity.components.set(CollisionComponent(shapes: [collisionShape]))
        entityMap[anchor.id] = planeEntity
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
