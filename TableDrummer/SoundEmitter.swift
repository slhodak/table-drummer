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
    var entity: Entity?
    var audioPlaybackController: AudioPlaybackController?
    
    init?(for audioFileName: String) {
        do {
            let emitterEntity = try Entity.load(named: "Geometry/sound-emitter", in: tableDrummerContentBundle)
            let resource = try AudioFileResource.load(named: audioFileName)
            
            emitterEntity.scale = [0.1, 0.1, 0.1]
            emitterEntity.name = "\(audioFileName)_emitter"
            
            // It may be redundant to call .set() and add the component in Composer, but it's not working without this
            emitterEntity.components.set(IdentifierComponent())
            emitterEntity.components[IdentifierComponent.self]?.sharedId = audioFileName
            emitterEntity.spatialAudio = SpatialAudioComponent()
            
            self.entity = emitterEntity
            self.audioPlaybackController = emitterEntity.prepareAudio(resource)
        } catch {
            print("Error initializing sound emitter entity \(audioFileName)")
            print(error.localizedDescription)
            return nil
        }
    }
}
