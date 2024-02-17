//
//  ContentView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    var debugText: String
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        VStack {
//            DebugView(debugText: debugText)
            if !immersiveSpaceIsShown {
                VStack(alignment: .leading) {
                    Text("How to Play")
                        .font(.largeTitle)
                    Text("1. Move the square pads into arm's reach with Eye Tracking + Pinch Gesture.\n\tFor best results move them onto a table with the bottom of the pad below the surface of the table.")
                    Text("2. Tap the pads with your index fingers to trigger sounds.")
                    Text("3. Each pad has a speaker. Move the speaker to move the source of the sound.")
                }
            }
            
            Toggle(immersiveSpaceIsShown ? "Stop": "Start", isOn: $showImmersiveSpace)
                .toggleStyle(.button)
                .padding(.top, 50)
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}
