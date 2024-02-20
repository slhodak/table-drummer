//
//  Colors.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/17/24.
//

import Foundation
import RealityKit
import SwiftUI


struct TDColor {
    // Blues
    static let a = RealityFoundation.Material.Color(red: 0.216, green: 0.322, blue: 0.941, alpha: 1.0)
    static let b = RealityFoundation.Material.Color(red: 0.216, green: 0.690, blue: 0.941, alpha: 1.0)
    static let c = RealityFoundation.Material.Color(red: 0.216, green: 0.918, blue: 0.941, alpha: 1.0)
    
    // Green-Yellow-Reds
    static let d = RealityFoundation.Material.Color(red: 0.646, green: 0.941, blue: 0.216, alpha: 1.0)
    static let e = RealityFoundation.Material.Color(red: 0.941, green: 0.933, blue: 0.216, alpha: 1.0)
    static let f = RealityFoundation.Material.Color(red: 0.941, green: 0.725, blue: 0.216, alpha: 1.0)
    static let g = RealityFoundation.Material.Color(red: 0.941, green: 0.380, blue: 0.216, alpha: 1.0)
    
    // Purple-Magentas
    static let h = RealityFoundation.Material.Color(red: 0.941, green: 0.216, blue: 0.510, alpha: 1.0)
    static let i = RealityFoundation.Material.Color(red: 0.941, green: 0.216, blue: 0.922, alpha: 1.0)
}


struct TDColorView: View {
    var body: some View {
        VStack {
            Color(TDColor.a)
            Color(TDColor.b)
            Color(TDColor.c)
            Color(TDColor.d)
            Color(TDColor.e)
            Color(TDColor.f)
            Color(TDColor.g)
            Color(TDColor.h)
            Color(TDColor.i)
        }
    }
}


struct TDColorView_Previews: PreviewProvider {
    static var previews: some View {
        TDColorView()
    }
}
