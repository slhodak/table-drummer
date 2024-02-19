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
        .onDisappear() {
            rootEntity = nil
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                value.entity.position = value.convert(value.location3D,
                                                      from: .local,
                                                      to: value.entity.parent!)
            })
        .gesture(RotateGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                print(value.rotation)
                let radians = Float(value.rotation.radians)
                value.entity.orientation = simd_quatf(angle: radians, axis: [0, 1, 0])
            })
    }
    
    private func setupRootEntity() {
        rootEntity = Entity()
        guard let rootEntity = rootEntity else { return }
        rootEntity.name = "root"
    }
    
    private func handleCollisionBegan(_ ce: CollisionEvents.Began) {
        if ce.entityA.name.contains("Pad") && ce.entityB.name.contains("Fingertip") {
            drumsModel.playSoundForPad(entity: ce.entityA)
        } else if ce.entityA.name.contains("Fingertip") && ce.entityB.name.contains("Pad") {
            drumsModel.playSoundForPad(entity: ce.entityB)
        }
    }
}
