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
    static func create(index: Int) -> Entity? {
        do {
            let padEntity = try Entity.load(named: "simple-pad", in: tableDrummerContentBundle)
            padEntity.scale = [0.06, 0.06, 0.06]
            padEntity.name = "drum_pad_\(index)"
            
            return padEntity
        } catch {
            print("Could not load pad \(index)")
            print(error.localizedDescription)
        }
        
        return nil
    }
}
