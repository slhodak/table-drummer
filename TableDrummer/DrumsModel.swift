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
    
    let audioSamples: [String: [String: RealityFoundation.Material.Color]] = [
        "core": [
            "rock-kick-2": TDColor.a,
            "indie-rock-snare": TDColor.b,
            "heavy-rock-closed-hi-hat": TDColor.c,
        ],
        "toms": [
            "heavy-rock-tom": TDColor.d,
            "heavy-rock-tom-2": TDColor.e,
            "heavy-rock-tom-3": TDColor.f,
            "heavy-rock-floor-tom": TDColor.g,
        ],
        "cymbals": [
            "heavy-rock-ride": TDColor.h,
            "golden-crash": TDColor.i,
        ]
    ]
    
    func setupEntity() -> Entity {
        let padSpacing: Float = 0.2
        let totalWidth: Float = 1.0
        let leftmostParentX = totalWidth/2 * -1
        let parentSpacing: Float = totalWidth/Float(audioSamples.count)
        var i = 0
        
        for (sampleType, sampleSet) in audioSamples {
            guard  let firstSample = sampleSet.first else {
                print("Error getting the first element in the Sets:Samples:Colors dict")
                continue
            }
            
            // Create + place parent orbs
            let (_, parentsColor) = firstSample
            let parentX = leftmostParentX + parentSpacing * Float(i+1)
            
            let parentPosition = SIMD3<Float>(parentX, 0.75, -0.5)
            let (padsParent, emittersParent) = createPadAndEmitterParents(position: parentPosition, color: parentsColor)
            
            let padSetWidth = padSpacing * Float(sampleSet.count - 1)
            var j = 0
            
            for (sampleName, color) in sampleSet {
                // Only add pad and emitter if both can be made
                guard let pad = DrumPad(name: sampleName),
                      let emitter = SoundEmitter(name: sampleName) else { continue }
                
                setPadEmitterPairColor(pad: pad, emitter: emitter, color: color)
                linkPadToEmitter(pad: pad, emitter: emitter, identifier: sampleName)
                
                let padX = (padSetWidth/2 * -1) + (padSpacing * Float(j))
                let padZ: Float = 0.1
                pad.entity.position = [padX, -0.1, padZ]
                
                emitter.entity.position = [padX, 0.1, padZ]
                
                padsParent.addChild(pad.entity)
                emittersParent.addChild(emitter.entity)
                
                j += 1
            }
            
            contentEntity.addChild(padsParent)
            contentEntity.addChild(emittersParent)
            
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
        
        padCornersModelEntity.model?.materials = [getPadColorMaterial(color: color)]
        emitterStripesModelEntity.model?.materials = [getEmitterColorMaterial(color: color)]
    }
    
    private func createPadAndEmitterParents(position: SIMD3<Float>, color: RealityFoundation.Material.Color) -> (ModelEntity, ModelEntity) {
        let parentSphereRadius: Float = 0.04
        
        let padsParent = ModelEntity(mesh: .generateSphere(radius: parentSphereRadius),
                                     materials: [getPadColorMaterial(color: color)],
                                     collisionShape: .generateSphere(radius: parentSphereRadius),
                                     mass: 0.0)
        padsParent.components.set(PhysicsBodyComponent(mode: .kinematic))
        padsParent.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        
        let emittersParent = ModelEntity(mesh: .generateSphere(radius: parentSphereRadius),
                                         materials: [getEmitterColorMaterial(color: color)],
                                         collisionShape: .generateSphere(radius: parentSphereRadius),
                                         mass: 0.0)
        emittersParent.components.set(PhysicsBodyComponent(mode: .kinematic))
        emittersParent.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        
        let yOffset = parentSphereRadius * 1.05
        padsParent.position = position
        padsParent.position.y -= yOffset
        emittersParent.position = position
        emittersParent.position.y += yOffset
        
        return (padsParent, emittersParent)
    }
    
    private func getPadColorMaterial(color: RealityFoundation.Material.Color) -> SimpleMaterial {
        SimpleMaterial(color: color, roughness: 0.75, isMetallic: false)
    }
    
    private func getEmitterColorMaterial(color: RealityFoundation.Material.Color) -> SimpleMaterial {
        SimpleMaterial(color: color, roughness: 0.25, isMetallic: true)
    }
}
