//
//  DebugView.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/8/24.
//

import Foundation
import SwiftUI


struct DebugView: View {
    var debugText: String
    
    var body: some View {
        VStack {
            Text("Debugging")
            Text(debugText)
        }
        .padding()
        .border(.white.secondary, width: 1)
        
    }
}
