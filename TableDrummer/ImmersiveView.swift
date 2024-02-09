//
//  ImmersiveView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit
import Combine
import TableDrummerContent


struct ImmersiveView: View {
    @State private var emitters: [String: SoundEmitter] = [:]
    @State private var pads: [Entity] = []
    @Binding var debugText: String
    var cannotDragElements: Bool
    
    let colors: [RealityFoundation.Material.Color] = [.blue, .red, .green, .yellow]
    let audioSamples: [String] = [
        "rock-kick-2",
        "indie-rock-snare",
        "heavy-rock-closed-hi-hat",
        "heavy-rock-floor-tom",
//        "heavy-rock-tom-3",
//        "heavy-rock-tom-2",
//        "heavy-rock-tom"
    ]
    
    // Todo: Can position all pads as a group
    
    var body: some View {
        RealityView { content in
            let spacing: Float = 0.22
            var i = 0
            let allPadsInitialWidth = spacing * Float(audioSamples.count - 1)
            
            for sampleName in audioSamples {
                // Only add pad and emitter if both can be made
                guard let pad = DrumPad.create(for: sampleName),
                      let emitter = SoundEmitter(for: sampleName) else { continue }
                
                linkPadToEmitter(pad: pad, emitter: emitter, identifier: sampleName)
                
                pad.position = [(allPadsInitialWidth/2 * -1) + (spacing * Float(i)), 1, -1.0]
                emitter.entity?.position = [pad.position[0], pad.position[1] + 0.25, pad.position[2]]
                
                content.add(pad)
                content.add(emitter.entity!)
                pads.append(pad)
                i += 1
            }
            
        }
        .gesture(SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { gesture in
                print(gesture.entity)
                
                let padIdentifierTransform = gesture.entity.findEntity(named: "IdentifierTransform")
                
                guard let padIdentifier: String = padIdentifierTransform?.children[0].name else {
                    print("No identifier found on tapped entity \(gesture.entity.name)")
                    return
                }
                
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
            })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard cannotDragElements == false else { return }
                
                value.entity.position = value.convert(value.location3D,
                                                      from: .local, to: value.entity.parent!)
            })
    }
    
    private func linkPadToEmitter(pad: Entity, emitter: SoundEmitter, identifier: String) {
        let padIdentifier = identifier
        let padIdTransform = pad.findEntity(named: "MutableId")
        padIdTransform?.name = padIdentifier
        
        emitters[padIdentifier] = emitter
        let emitterIdTransform = emitter.entity?.findEntity(named: "MutableId")
        emitterIdTransform?.name = padIdentifier // not used on this entity for now
    }
    
    private func addTestSphere(to content: RealityViewContent) {
        let sphere = MeshResource.generateSphere(radius: 0.3)
        let sEntity = ModelEntity(mesh: sphere, materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        sEntity.components.set(InputTargetComponent())
        sEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.3)]))
        sEntity.name = "my_custom_sphere"
        print(sEntity.name)
        content.add(sEntity)
    }
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}


var padNames: [String] = []
