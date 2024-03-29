//
//  ElementsView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/19/24.
//

import Foundation
import SwiftUI
import RealityKit
import TableDrummerContent

struct ElementsView: View {
    var body: some View {
        HStack {
            Text("Pad")
            Model3D(named: "Geometry/pad-tall", bundle: tableDrummerContentBundle) { phase in
                if let model = phase.model {
                    model.resizable()
                        .rotation3DEffect(Angle(degrees: -75), axis: (0.5, 0.2, -0.5))
                        .scaledToFit()
                        .frame(width: 40)
                } else if phase.error != nil {
                    Color.red
                } else {
                    ProgressView()
                }
            }
            .padding()
            
            Text("Speaker")
            Model3D(named: "Geometry/striped-emitter", bundle: tableDrummerContentBundle) { phase in
                if let model = phase.model {
                    model.resizable()
                        .scaledToFit()
                        .frame(width: 40)
                } else if phase.error != nil {
                    Color.red
                } else {
                    ProgressView()
                }
            }
            .padding()
            
            Text("Pad Handle")
            RealityView { content in
                let matteOrb = ParentHandle.createOrb(radius: 0.015, color: .gray, isMetallic: false)
                matteOrb.position.z -= 0.175
                content.add(matteOrb)
            }
            
            Text("Speaker Handle")
            RealityView { content in
                let metallicOrb = ParentHandle.createOrb(radius: 0.015, color: .gray, isMetallic: true)
                metallicOrb.position.z -= 0.175
                content.add(metallicOrb)
            }
        }
    }
}
