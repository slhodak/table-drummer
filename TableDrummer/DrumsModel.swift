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
    private var contentEntity = Entity()
    private var emitters = [String: SoundEmitter]()
    private var pads = [String: DrumPad]()
    private let tapDelayRequiredSeconds = 0.1
    
    let audioSamples: [String: RealityFoundation.Material.Color] = [
        "rock-kick-2": TDColor.a,
        "indie-rock-snare": TDColor.b,
        "heavy-rock-closed-hi-hat": TDColor.c,
        "heavy-rock-tom": TDColor.d,
        "heavy-rock-tom-2": TDColor.e,
        "heavy-rock-tom-3": TDColor.f,
        "heavy-rock-floor-tom": TDColor.g,
        "heavy-rock-ride": TDColor.h,
        "golden-crash": TDColor.i,
    ]
    
    func setupEntity() -> Entity {
        let spacing: Float = 0.16
        var i = 0
        let allPadsInitialWidth = spacing * Float(audioSamples.count - 1)
        
        for (sampleName, color) in audioSamples {
            // Only add pad and emitter if both can be made
            guard let pad = DrumPad(name: sampleName),
                  let emitter = SoundEmitter(name: sampleName) else { continue }
            
            setPadEmitterPairColor(pad: pad, emitter: emitter, color: color)
            linkPadToEmitter(pad: pad, emitter: emitter, identifier: sampleName)
            
            pad.entity.position = [(allPadsInitialWidth/2 * -1) + (spacing * Float(i)), 1, -0.5]
            emitter.entity.position = [
                pad.entity.position[0],
                pad.entity.position[1] + 0.25,
                pad.entity.position[2]
            ]
            
            contentEntity.addChild(pad.entity)
            contentEntity.addChild(emitter.entity)
            
            i += 1
        }
        
        return contentEntity
    }
    
    func playSoundForPad(entity: Entity) {
        guard let (pad, emitter) = getPadAndEmitterFor(entity: entity) else { return }
        
        let now = Date().timeIntervalSince1970
        if now - pad.lastTap > tapDelayRequiredSeconds {
            pad.lastTap = now
            playSoundFrom(emitter)
        }
    }
    
    private func getPadAndEmitterFor(entity: Entity) -> (DrumPad, SoundEmitter)? {
        let padIdentifierTransform = entity.findEntity(named: "IdentifierTransform")
        
        guard let padIdentifier: String = padIdentifierTransform?.children[0].name else {
            print("No identifier found on tapped entity \(entity.name)")
            return nil
        }
        
        guard let pad = pads[padIdentifier] else {
            print("No saved pad for identifier \(padIdentifier)")
            return nil
        }
        
        guard let emitter = emitters[padIdentifier] else {
            print("No emitter for identifer \(padIdentifier)")
            return nil
        }
        
        return (pad, emitter)
    }
    
    private func playSoundFrom(_ emitter: SoundEmitter) {
        guard let audioPlaybackController = emitter.audioPlaybackController else {
            print("No audio playback controller on emitter \(emitter.name)")
            return
        }
        
        if audioPlaybackController.isPlaying {
            audioPlaybackController.stop()
        }
        
        audioPlaybackController.play()
    }
    
    private func linkPadToEmitter(pad: DrumPad, emitter: SoundEmitter, identifier: String) {
        guard let padIdTransform = pad.entity.findEntity(named: "MutableId") else {
            print("No MutableId transform found on pad \(pad.entity.name)")
            return
        }
        
        guard let emitterIdTransform = emitter.entity.findEntity(named: "MutableId") else {
            print("No MutableId transform found on emitter entity \(emitter.entity.name)")
            return
        }

        padIdTransform.name = identifier
        emitters[identifier] = emitter
        emitterIdTransform.name = identifier
        pads[identifier] = pad
    }
    
    private func setPadEmitterPairColor(pad: DrumPad, emitter: SoundEmitter, color: RealityFoundation.Material.Color) {
        guard let emitterStripesModelEntity = emitter.entity.findEntity(named: "EmitterStripesMesh") as? ModelEntity,
              let padCornersModelEntity = pad.entity.findEntity(named: "PadCornersMesh") as? ModelEntity else {
            print("Could not find stripes and corners entities")
            return
        }
        let colorMaterial = SimpleMaterial(color: color, roughness: 0.7, isMetallic: false)
        emitterStripesModelEntity.model?.materials = [colorMaterial]
        padCornersModelEntity.model?.materials = [colorMaterial]
    }
}
