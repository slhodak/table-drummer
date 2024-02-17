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
        let authorizationResult = await arSession.requestAuthorization(for: [.handTracking])
        
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
            try await arSession.run([handTracking])
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
        entity.components.set(OpacityComponent(opacity: 0.0))
        
        return entity
    }
}
