//
//  ViewModel.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import Foundation
import SwiftUI
import RealityKit


class ViewModel: Observable {
    func tapDrum(gesture: EntityTargetValue<SpatialTapGesture.Value>) {
        print("Tapped \(gesture)")
    }
}
