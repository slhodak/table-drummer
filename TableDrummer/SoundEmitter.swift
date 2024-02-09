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
            let emitterEntity = try Entity.load(named: "Geometry/striped-emitter", in: tableDrummerContentBundle)
            let resource = try AudioFileResource.load(named: audioFileName)
            
            emitterEntity.scale = [0.1, 0.1, 0.1]
            emitterEntity.name = "\(audioFileName)_emitter"
            
            self.entity = emitterEntity
            self.audioPlaybackController = emitterEntity.prepareAudio(resource)
        } catch {
            print("Error initializing sound emitter entity \(audioFileName)")
            print(error.localizedDescription)
            return nil
        }
    }
}
