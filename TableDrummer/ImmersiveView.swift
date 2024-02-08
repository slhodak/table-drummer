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
    @Environment(ViewModel.self) private var viewModel
    @State var tapCount: Int = 0
    var drumPadCount = 4
    @Binding var debugText: String
    @State var planeEntity: Entity = {
        let tableAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: SIMD2<Float>(0.1, 0.1)))
        return tableAnchor
    }()
    
    // pads appear in front of you
    // you can position them as a group and individually on top of the table
    // pad has an area that allows for moving it (but not rotating it)
    // can disable all handles
    // app encourages you to adjust height to combat latency -- a fine Y adjustment slider
    
    var body: some View {
        RealityView { content in
            let spacing: Float = 0.25
            for i in 0..<drumPadCount {
                // Only add pad and drum if both can be made
                guard let pad = DrumPad.create(index: i),
                      let emitter = SoundEmitter.create() else { continue }
                
                // Todo: connect the pad to the emitter
                
                pad.position = [0.0  + (spacing * Float(i)), 1.0, 0.0]
                content.add(pad)
                emitter.position = [0.0  + (spacing * Float(i)), 1.4, 0.0]
                content.add(emitter)
            }
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded {
            gesture in
            tapCount += 1
            debugText = "taps: \(tapCount)"
            viewModel.tapDrum(gesture: gesture)
        })
    }
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}
