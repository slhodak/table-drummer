//
//  ImmersiveView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit
import TableDrummerContent


struct ImmersiveView: View {
    @State private var emitters: [String: SoundEmitter] = [:]
    @Binding var debugText: String
    var cannotDragElements: Bool
    let audioSamples: [String] = [
        "rock-kick-2",
        "indie-rock-snare",
        "heavy-rock-closed-hi-hat",
        "heavy-rock-floor-tom",
        "heavy-rock-tom-3",
        "heavy-rock-tom-2",
        "heavy-rock-tom"
    ]
    
    // you can position them as a group and individually on top of the table
    // app encourages you to adjust height to combat latency -- a fine Y adjustment slider
    
    var body: some View {
        RealityView { content in
            let spacing: Float = 0.22
            var i = 0
            for sampleName in audioSamples {
                // Only add pad and drum if both can be made
                guard let pad = DrumPad.create(for: sampleName),
                      let emitter = SoundEmitter(for: sampleName) else { continue }
                
                // Todo: connect the pad to the emitter
                guard let sharedId = emitter.entity?.components[IdentifierComponent.self]?.sharedId else { continue }
                
                emitters[sharedId] = emitter
                
                pad.position = [0.0 + (spacing * Float(i)), 1, -1.0]
                content.add(pad)
                emitter.entity?.position = [0.0 + (spacing * Float(i)), 1.2, -1.0]
                content.add(emitter.entity!)
                i += 1
                
//                print(emitter.entity?.components[IdentifierComponent.self]?.sharedId)
//                print(pad.components[IdentifierComponent.self]?.sharedId)
            }
        }
        .gesture(SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { gesture in
                guard let sharedId = gesture.entity.components[IdentifierComponent.self]?.sharedId else {
                    print("Error getting sharedId from gesture")
                    return
                }
                
                guard let emitter = emitters[sharedId] else {
                    print("Could not find emitter by sharedId \(sharedId)")
                    return
                }
                
                emitter.audioPlaybackController?.play()
            })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard cannotDragElements == false else { return }
                
                value.entity.position = value.convert(value.location3D,
                                                      from: .local, to: value.entity.parent!)
            })
    }
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}
