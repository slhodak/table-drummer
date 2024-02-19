//
//  ContentView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import RealityKit
import TableDrummerContent


struct ContentView: View {
    var debugText: String
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        VStack {
            if !immersiveSpaceIsShown {
                VStack(alignment: .leading) {
                    Text("How to Play")
                        .font(.largeTitle)
                    
                    ElementsView()
                    
                    Text("1. Tap a pad to produce sound from its associated speaker.")
                    Text("2. Pads and speakers can all be moved.")
                    Text("3. Pad groups can be moved by their associated matte orb.")
                    Text("4. Speaker groups can be moved by their associated metallic orb.")
                    Text("\nTry placing the pads on a table and tapping the table. Have fun!")
                }
                .padding()
            }
            
            Toggle(immersiveSpaceIsShown ? "Stop": "Start", isOn: $showImmersiveSpace)
                .toggleStyle(.button)
                .padding()
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
