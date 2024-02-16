//
//  ImmersiveView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit
import ARKit


struct ImmersiveView: View {
    let planeDetectionModel = PlaneDetectionModel()
    let drumsModel = DrumsModel()
    
    @Binding var debugText: String
    var cannotDragElements: Bool
    var gravityIsEnabled: Bool
    let gravity: SIMD3<Float> = [0, -0.5, 0]
    
    var body: some View {
        RealityView { content in
            content.add(drumsModel.setupEntity())
        } update: { content in
           handleGravityToggle(content: content)
        }
//        .task {
//            await planeDetectionModel.authorize()
//        }
//        .task {
//            if planeDetectionModel.authorized {
//                await planeDetectionModel.detectPlanes()
//            }
//        }
//        .task {
//            if planeDetectionModel.authorized {
//                await planeDetectionModel.updatePlanes()
//            }
//        }
        .gesture(SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                guard value.entity.name.contains("Pad") else { return }
                
                drumsModel.playSoundForPad(entity: value.entity)
            })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                if value.entity.name.contains("Pad") &&
                    cannotDragElements == true {
                    return
                }
                
                value.entity.position = value.convert(value.location3D,
                                                      from: .local,
                                                      to: value.entity.parent!)
            })
    }
    
    private func handleGravityToggle(content: RealityViewContent) {
        let root = content.entities[0]
        if gravityIsEnabled {
            root.components[PhysicsSimulationComponent.self]?.gravity = gravity
        } else {
            root.components[PhysicsSimulationComponent.self]?.gravity = [0, 0, 0]
            
            // Reset pad physics body components to halt falling
            let physicsQuery = EntityQuery(where: .has(PhysicsBodyComponent.self))
            root.scene?.performQuery(physicsQuery).forEach { entity in
                // may want to alter this so it only affects pads, because planes may also need physics body components and its just unnecessary to replace them since they won't be affected by gravity (and could cause unexpected behavior)
                entity.components.remove(PhysicsBodyComponent.self)
                entity.components.set(PhysicsBodyComponent())
            }
        }
    }
}
