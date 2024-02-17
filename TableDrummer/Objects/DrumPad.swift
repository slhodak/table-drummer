//
//  DrumPads.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import Foundation
import RealityKit
import TableDrummerContent


class DrumPad: ObservableObject {
    static func create(for audioFileName: String) -> Entity? {
        do {
            let padEntity = try Entity.load(named: "Geometry/pad-tall", in: tableDrummerContentBundle)
            padEntity.scale = [0.05, 0.025, 0.05]
            padEntity.components.set(PadMarkerComponent(name: audioFileName))
            
            return padEntity
            
        } catch {
            print("Could not load pad \(audioFileName)")
            print(error.localizedDescription)
            return nil
        }
    }
}
