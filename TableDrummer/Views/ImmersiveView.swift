//
//  ImmersiveView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import TableDrummerContent


struct ImmersiveView: View {
    @State private var emitters: [String: SoundEmitter] = [:]
    @State private var pads: [Entity] = []
    @Binding var debugText: String
    var cannotDragElements: Bool
    var gravityIsEnabled: Bool
    let gravity: SIMD3<Float> = [0, -0.5, 0]
    let arSession = ARKitSession()
    let planeData = PlaneDetectionProvider(alignments: [.horizontal])
    
    let colors: [RealityFoundation.Material.Color] = [.blue, .red, .green, .yellow]
    let audioSamples: [String] = [
        "rock-kick-2",
        "indie-rock-snare",
        "heavy-rock-closed-hi-hat",
        "heavy-rock-floor-tom"
    ]
    
    var body: some View {
        RealityView { content in
            var root = Entity()
            let spacing: Float = 0.22
            var i = 0
            let allPadsInitialWidth = spacing * Float(audioSamples.count - 1)
            
            var physicsSimulationComponent = PhysicsSimulationComponent()
            physicsSimulationComponent.gravity = [0, 0, 0]
            root.components.set(physicsSimulationComponent)
            root.name = "root"
            
            for sampleName in audioSamples {
                // Only add pad and emitter if both can be made
                guard let pad = DrumPad.create(for: sampleName),
                      let emitter = SoundEmitter(for: sampleName) else { continue }
                
                linkPadToEmitter(pad: pad, emitter: emitter, identifier: sampleName)
                
                pad.position = [(allPadsInitialWidth/2 * -1) + (spacing * Float(i)), 1, -1.0]
                emitter.entity?.position = [pad.position[0], pad.position[1] + 0.25, pad.position[2]]
                
                
                root.addChild(pad)
                root.addChild(emitter.entity!)
                pads.append(pad)
                
                i += 1
            }
            
            content.add(root)
            
//            enablePlaneDetection()
        } update: { content in
            print(gravityIsEnabled)
            let root = content.entities[0]
            if gravityIsEnabled {
                root.components[PhysicsSimulationComponent.self]?.gravity = gravity
            } else {
                root.components[PhysicsSimulationComponent.self]?.gravity = [0, 0, 0]
                
                // Reset pad physics body components to halt falling
                let physicsQuery = EntityQuery(where: .has(PhysicsBodyComponent.self))
                root.scene?.performQuery(physicsQuery).forEach { entity in
                    entity.components.remove(PhysicsBodyComponent.self)
                    entity.components.set(PhysicsBodyComponent())
                }
            }
        }
        .gesture(SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                guard value.entity.name.contains("Pad") else { return }
                
                let padIdentifierTransform = value.entity.findEntity(named: "IdentifierTransform")
                
                guard let padIdentifier: String = padIdentifierTransform?.children[0].name else {
                    print("No identifier found on tapped entity \(value.entity.name)")
                    return
                }
                
                playSoundFromEmitter(by: padIdentifier)
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
    
    private func updatePlane(_ anchor: PlaneAnchor) async {
        
    }
    
    private func removePlane(_ anchor: PlaneAnchor) async {
        
    }
    
    private func playSoundFromEmitter(by padIdentifier: String) {
        guard let emitter = emitters[padIdentifier] else {
            print("No emitter for identifer \(padIdentifier)")
            return
        }
        
        guard let audioPlaybackController = emitter.audioPlaybackController else {
            print("No audio playback controller on emitter \(padIdentifier)")
            return
        }
        
        if audioPlaybackController.isPlaying {
            audioPlaybackController.stop()
        }
        
        audioPlaybackController.play()
    }
    
    private func linkPadToEmitter(pad: Entity, emitter: SoundEmitter, identifier: String) {
        let padIdentifier = identifier
        let padIdTransform = pad.findEntity(named: "MutableId")
        padIdTransform?.name = padIdentifier
        
        emitters[padIdentifier] = emitter
        let emitterIdTransform = emitter.entity?.findEntity(named: "MutableId")
        emitterIdTransform?.name = padIdentifier // not used on this entity for now
    }
    
    // Todo: Finish
    // detect table planes
    // add colliders to them
    private func enablePlaneDetection() {
#if !targetEnvironment(simulator)
        Task {
            try await arSession.run([planeData])
            for await update in planeData.anchorUpdates {
                switch update .event {
                case .added, .updated:
                    await updatePlane(update.anchor)
                case .removed:
                    await removePlane(update.anchor)
                }
            }
        }
#endif
    }
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}


var padNames: [String] = []
