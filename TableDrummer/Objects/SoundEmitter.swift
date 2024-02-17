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
    var name: String
    var entity: Entity
    var audioPlaybackController: AudioPlaybackController?
    
    init?(name audioFileName: String) {
        do {
            let emitterEntity = try Entity.load(named: "Geometry/striped-emitter", in: tableDrummerContentBundle)
            guard let spatialAudioTransform = emitterEntity.findEntity(named: "SpatialAudioTransform") else {
                print("Could not find SpatialAudioTransform on emitter for \(audioFileName)")
                return nil
            }
            
            let resource = try AudioFileResource.load(named: audioFileName)
            
            emitterEntity.scale = [0.05, 0.05, 0.05]
            emitterEntity.name = "\(audioFileName)_emitter"
            
            self.name = audioFileName
            self.entity = emitterEntity
            self.audioPlaybackController = spatialAudioTransform.prepareAudio(resource)
        } catch {
            print("Error initializing sound emitter entity \(audioFileName)")
            print(error.localizedDescription)
            return nil
        }
    }
}
