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
            let padEntity = try Entity.load(named: "Geometry/drum-pad", in: tableDrummerContentBundle)
            padEntity.scale = [0.025, 0.025, 0.025]
            
            return padEntity
            
        } catch {
            print("Could not load pad \(audioFileName)")
            print(error.localizedDescription)
            return nil
        }
    }
}
