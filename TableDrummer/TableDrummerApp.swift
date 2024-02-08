//
//  TableDrummerApp.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import SwiftUI

@main
struct TableDrummerApp: App {
    @State private var viewModel = ViewModel()
    @State var debugText = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView(debugText: debugText)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(debugText: $debugText)
                .environment(viewModel)
        }
    }
}
