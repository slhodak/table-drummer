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
    var name: String
    var entity: Entity
    var lastTap = Date().timeIntervalSince1970
    
    init?(name audioFileName: String) {
        do {
            let padEntity = try Entity.load(named: "Geometry/pad-tall", in: tableDrummerContentBundle)
            padEntity.scale = [0.05, 0.05, 0.025]
            padEntity.components.set(PadMarkerComponent(name: audioFileName))
            
            self.entity = padEntity
            self.name = audioFileName
        } catch {
            print("Could not load pad \(audioFileName)")
            print(error.localizedDescription)
            return nil
        }
    }
}
