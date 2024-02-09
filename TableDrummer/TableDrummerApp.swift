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
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(debugText: $debugText, cannotDragElements: cannotDragElements)
        }
    }
}
