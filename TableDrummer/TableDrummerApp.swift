//
//  TableDrummerApp.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import TableDrummerContent

let goldenRatio = 1.618

@main
struct TableDrummerApp: App {
    @State var debugText = ""
    @State private var cannotDragElements: Bool = false
    @State private var gravityIsEnabled: Bool = false
    
    private var windowHeight = 0.3
    
    init() {
        PadMarkerComponent.registerComponent()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(debugText: debugText)
        }
        .defaultSize(width: windowHeight * goldenRatio, height: windowHeight, depth: 0.02, in: .meters)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(debugText: $debugText)
        }
    }
}
