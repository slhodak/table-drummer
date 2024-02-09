//
//  DrumPads.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/7/24.
//

import Foundation
import RealityKit
import TableDrummerContent


class DrumPad {
    static func create(for audioFileName: String) -> Entity? {
        do {
            let padEntity = try Entity.load(named: "Geometry/grippable-pad", in: tableDrummerContentBundle)
            padEntity.scale = [0.1, 0.1, 0.1]
            padEntity.name = "\(audioFileName)_pad"
            padEntity.components.set(IdentifierComponent())
            padEntity.components[IdentifierComponent.self]?.sharedId = audioFileName
            print(padEntity.components)
            
            return padEntity
            
        } catch {
            print("Could not load pad \(audioFileName)")
            print(error.localizedDescription)
            return nil
        }
    }
}
