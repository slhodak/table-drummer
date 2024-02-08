//
//  ImmersiveView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(ViewModel.self) private var viewModel
//    @State var planeEntity: Entity = {
//        let tableAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: SIMD2<Float>(0.1, 0.1)))
//        let drumPads = DrumPads.createPads(numPads: 4, addTo: tableAnchor)
//        return tableAnchor
//    }()
    
    var body: some View {
        RealityView { content in
            let drumPads = DrumPads.createPads(numPads: 4)
            for pad in drumPads {
                content.add(pad)
            }
           
            let sphereEntity = ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.2),
                materials: [SimpleMaterial(color: .green, isMetallic: false)]
            )
            sphereEntity.position = [0, 1, 0]
            content.add(sphereEntity)
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded {
            gesture in
            print("tapped!")
            viewModel.tapDrum(gesture: gesture)
        })
    }
}

//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}
