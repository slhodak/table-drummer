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


@MainActor class ARSessionModel: ObservableObject {
    private let arSession = ARKitSession()
    private let handTracking = HandTrackingProvider()
    private let sceneReconstruction = SceneReconstructionProvider()
    
    private var meshEntities = [UUID: ModelEntity]()
    private let fingerEntities: [HandAnchor.Chirality: ModelEntity] = [
        .left: .createFingertip("leftFingertip"),
        .right: .createFingertip("rightFingertip")
    ]
    
    private var contentEntity = Entity()
    
    func setupContentEntity() -> Entity {
        for entity in fingerEntities.values {
            contentEntity.addChild(entity)
        }
        
        return contentEntity
    }
    
    func authorize() async {
        let authorizationResult = await arSession.requestAuthorization(for: [.worldSensing, .handTracking])
        
        for (authorizationType, authorizationStatus) in authorizationResult {
            print("Authorization status for \(authorizationType): \(authorizationStatus)")
            switch authorizationStatus {
            case .allowed:
                break
            case .denied, .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    func runSession() async {
        do {
            await authorize()
            try await arSession.run([sceneReconstruction, handTracking])
        } catch {
            print("Error running session")
            print(error.localizedDescription)
        }
    }
    
    func processHandUpdates() async {
        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let handSkeleton = handAnchor.handSkeleton else { continue }
            
            let fingertip = handSkeleton.joint(.indexFingerTip)
            
            guard fingertip.isTracked else { continue }
            
            /*
             let originFromWrist = handAnchor.transform
             let wristFromIndex = fingertip.rootTransform
             let originFromIndex = originFromWrist * wristFromIndex
             */
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            let wristFromIndex = fingertip.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            
            fingerEntities[handAnchor.chirality]?.setTransformMatrix(originFromIndex, relativeTo: nil)
        }
    }
    
    func processReconstructionUpdates() async {
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor
            
            guard let shape = try? await ShapeResource.generateStaticMesh(from: meshAnchor) else { continue }
            
            switch update .event {
            case .added:
                let entity = createSceneMeshEntity(meshAnchor, shape)
                meshEntities[meshAnchor.id] = entity
                contentEntity.addChild(entity)
            case .updated:
                guard let entity = meshEntities[meshAnchor.id] else {
                    print("Update received for nonexistent meshAnchor")
                    continue
                }
                
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision?.shapes = [shape]
            case .removed:
                meshEntities[meshAnchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: meshAnchor.id)
            }
        }
    }
    
    private func createSceneMeshEntity(_ meshAnchor: MeshAnchor, _ shape: ShapeResource) -> ModelEntity {
        let entity = ModelEntity()
        entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
        entity.collision = CollisionComponent(shapes: [shape], isStatic: true)
        entity.physicsBody = PhysicsBodyComponent()
        
        return entity
    }
}


extension ModelEntity {
    class func createFingertip(_ name: String) -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateSphere(radius: 0.005),
            materials: [UnlitMaterial(color: .cyan)],
            collisionShape: .generateSphere(radius: 0.005),
            mass: 0.0)
        
        entity.name = name
        entity.components.set(PhysicsBodyComponent(mode: .kinematic))
//        entity.components.set(OpacityComponent(opacity: 1.0))
        
        return entity
    }
}
