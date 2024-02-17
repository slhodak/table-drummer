//
//  ImmersiveView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit
import TableDrummerContent
import ARKit


struct ImmersiveView: View {
    @State private var rootEntity: Entity?
    
    @StateObject var arSessionModel = ARSessionModel()
    @StateObject var drumsModel = DrumsModel()
    @State var collisionsSubscription: EventSubscription?
    
    @Binding var debugText: String
    var cannotDragElements: Bool
    var gravityIsEnabled: Bool
    let gravity: SIMD3<Float> = [0, -0.5, 0]
    
    var body: some View {
        RealityView { content in
            setupRootEntity()
            guard let rootEntity = rootEntity else {
                print("Missing root entity")
                return
            }
            
            rootEntity.addChild(drumsModel.setupEntity())
            rootEntity.addChild(arSessionModel.setupContentEntity())
            
            collisionsSubscription = content.subscribe(to: CollisionEvents.Began.self) { ce in
                self.handleCollisionBegan(ce)
            }
            
            content.add(rootEntity)
        }
        .task {
            await arSessionModel.runSession()
        }
        .task {
            await arSessionModel.processHandUpdates()
        }
        .task {
            await arSessionModel.processReconstructionUpdates()
        }
        .onDisappear() {
            rootEntity = nil
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                if value.entity.components[PadMarkerComponent.self] != nil &&
                    cannotDragElements == true {
                    return
                }
                
                value.entity.position = value.convert(value.location3D,
                                                      from: .local,
                                                      to: value.entity.parent!)
            })
    }
    
    private func setupRootEntity() {
        rootEntity = Entity()
        guard let rootEntity = rootEntity else { return }
        
        var physicsSimulationComponent = PhysicsSimulationComponent()
        physicsSimulationComponent.gravity = [0, 0, 0]
        rootEntity.components.set(physicsSimulationComponent)
        rootEntity.name = "root"
    }
    
    private func handleCollisionBegan(_ ce: CollisionEvents.Began) {
        guard ce.entityA.name.contains("Fingertip") || ce.entityB.name.contains("Fingertip") else { return }
        
        if ce.entityA.name.contains("Pad") {
            drumsModel.playSoundForPad(entity: ce.entityA)
        }  else if ce.entityB.name.contains("Pad") {
            drumsModel.playSoundForPad(entity: ce.entityB)
        }
    }
    
    private func handleGravityToggle(content: RealityViewContent) {
        let root = content.entities[0]
        let padsQuery = EntityQuery(where: .has(PadMarkerComponent.self))
        
        if gravityIsEnabled {
            root.components[PhysicsSimulationComponent.self]?.gravity = gravity

            root.scene?.performQuery(padsQuery).forEach { entity in
                entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
            }
            
        } else {
            root.components[PhysicsSimulationComponent.self]?.gravity = [0, 0, 0]
            
            root.scene?.performQuery(padsQuery).forEach { entity in
                entity.components[PhysicsBodyComponent.self]?.mode = .static
            }
        }
    }
}
