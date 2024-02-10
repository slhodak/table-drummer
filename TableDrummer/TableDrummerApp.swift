//
//  TableDrummerApp.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI
import TableDrummerContent


@main
struct TableDrummerApp: App {
    @State var debugText = ""
    @State private var cannotDragElements: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(debugText: debugText, cannotDragElements: $cannotDragElements)
        }
        .defaultSize(width: 0.3236, height: 0.2, depth: 0.5, in: .meters)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(debugText: $debugText, cannotDragElements: cannotDragElements)
        }
    }
}
