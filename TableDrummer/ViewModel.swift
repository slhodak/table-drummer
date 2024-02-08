//
//  ViewModel.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import Foundation
import SwiftUI
import RealityKit
import TableDrummerContent


class ViewModel: Observable {
    
    func tapDrum(gesture: EntityTargetValue<SpatialTapGesture.Value>) {
        do {
            let resource = try AudioFileResource.load(named: "rock-kick_140bpm_C", in: tableDrummerContentBundle)
            gesture.entity.playAudio(resource)
        } catch {
            print("Error loading audio file resource")
            print(error.localizedDescription)
        }
    }
}

