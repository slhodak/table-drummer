//
//  ImmersiveView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(ViewModel.self) private var viewModel
    @State var tapCount: Int = 0
    
    @Binding var debugText: String
//    @State var planeEntity: Entity = {
//        let tableAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: SIMD2<Float>(0.1, 0.1)))
//        let drumPads = DrumPads.createPads(numPads: 4, addTo: tableAnchor)
//        return tableAnchor
//    }()
    @State private var sphereEntity: ModelEntity?
    
    var body: some View {
        RealityView { content in
            let drumPads = DrumPads.createPads(numPads: 4)
            for pad in drumPads {
                content.add(pad)
            }
            
            sphereEntity = ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .green, isMetallic: false)]
            )
            if let sphereEntity = sphereEntity {
                sphereEntity.position = [0, 1, -1]
                content.add(sphereEntity)
            }
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded {
            gesture in
            tapCount += 1
            debugText = "taps: \(tapCount)"
            if let sphereEntity = sphereEntity {
                sphereEntity.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
            }
            viewModel.tapDrum(gesture: gesture)
        })
    }
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}
