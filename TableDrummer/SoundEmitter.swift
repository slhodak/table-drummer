//
//  SoundEmitter.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/8/24.
//

import Foundation
import RealityKit
import TableDrummerContent

class SoundEmitter {
    
    static func create() -> Entity? {
        do {
            let emitterEntity = try Entity.load(named: "sound-emitter-2", in: tableDrummerContentBundle)
            emitterEntity.scale = [0.1, 0.1, 0.1]
            return emitterEntity
        } catch {
            print("Error loading sound emitter entity")
            print(error.localizedDescription)
        }
        
        return nil
    }
}
