//
//  DrumsViewModel.swift
//  TableDrummer
//
//  Created by Sam Hodak on 2/15/24.
//

import Foundation
import RealityKit
import TableDrummerContent


class DrumsModel: ObservableObject {
    private var emitters: [String: SoundEmitter] = [:]
    private var pads: [Entity] = []
    
    let colors: [RealityFoundation.Material.Color] = [.blue, .red, .green, .yellow]
    let audioSamples: [String] = [
        "rock-kick-2",
        "indie-rock-snare",
        "heavy-rock-closed-hi-hat",
        "heavy-rock-floor-tom"
    ]
    
    func setupEntity() -> Entity {
        let root = Entity()
        let spacing: Float = 0.22
        var i = 0
        let allPadsInitialWidth = spacing * Float(audioSamples.count - 1)
        
        var physicsSimulationComponent = PhysicsSimulationComponent()
        physicsSimulationComponent.gravity = [0, 0, 0]
        root.components.set(physicsSimulationComponent)
        root.name = "root"
        
        for sampleName in audioSamples {
            // Only add pad and emitter if both can be made
            guard let pad = DrumPad.create(for: sampleName),
                  let emitter = SoundEmitter(for: sampleName) else { continue }
            
            // todo set drumpad color
            
            linkPadToEmitter(pad: pad, emitter: emitter, identifier: sampleName)
            
            pad.position = [(allPadsInitialWidth/2 * -1) + (spacing * Float(i)), 1, -1.0]
            emitter.entity?.position = [pad.position[0], pad.position[1] + 0.25, pad.position[2]]
            
            root.addChild(pad)
            root.addChild(emitter.entity!)
            pads.append(pad)
            
            i += 1
        }
        
        return root
    }
    
    func playSoundForPad(entity: Entity) {
        if let emitter = getEmitterFromPadEntity(entity: entity) {
            playSoundFrom(emitter)
        }
    }
    
    func getEmitterFromPadEntity(entity: Entity) -> SoundEmitter? {
        let padIdentifierTransform = entity.findEntity(named: "IdentifierTransform")
        
        guard let padIdentifier: String = padIdentifierTransform?.children[0].name else {
            print("No identifier found on tapped entity \(entity.name)")
            return nil
        }
        
        guard let emitter = emitters[padIdentifier] else {
            print("No emitter for identifer \(padIdentifier)")
            return nil
        }
        
        return emitter
    }
    
    func playSoundFrom(_ emitter: SoundEmitter) {
        guard let audioPlaybackController = emitter.audioPlaybackController else {
            print("No audio playback controller on emitter \(emitter.name)")
            return
        }
        
        if audioPlaybackController.isPlaying {
            audioPlaybackController.stop()
        }
        
        audioPlaybackController.play()
    }
    
    private func linkPadToEmitter(pad: Entity, emitter: SoundEmitter, identifier: String) {
        guard let padIdTransform = pad.findEntity(named: "MutableId") else {
            print("No MutableId transform found on pad \(pad.name)")
            return
        }
        
        guard let emitterIdTransform = emitter.entity?.findEntity(named: "MutableId") else {
            print("No MutableId transform found on emitter entity \(emitter.entity?.name ?? "")")
            return
        }
        
        padIdTransform.name = identifier
        emitters[identifier] = emitter
        emitterIdTransform.name = identifier // not used on this entity for now
    }
}
