//
//  ARViewModel.swift
//  SimpleARKitVision
//
//  Created by John Haney (Lextech) on 3/31/24.
//

import ARKit
import RealityKit

@Observable
@MainActor
class ARViewModel: ARUnderstandingModel {
    let handTracking = HandTrackingProvider()
    
    let imageTracking = ImageTrackingProvider(
        referenceImages: ReferenceImage.loadReferenceImages(inGroupNamed: "AR Resources")
    )
    
    let planeDetection = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
    
    let sceneProvider = SceneReconstructionProvider(modes: [.classification])
    
    let worldTracking = WorldTrackingProvider()
    
    init() {
        // NOTE: You should only use what you need, and be sure to only ask for the permissions you need for those
        super.init(providers: [
            .image(imageTracking),
            .planes(planeDetection),
            .hands(handTracking),
            .meshes(sceneProvider),
            .world(worldTracking),
        ])
    }
    
    override func update(_ hand: HandAnchor) async {
        switch hand.chirality {
        case .right:
            // Right hand anchor
            break
        case .left:
            // Left hand anchor
            break
        }
    }
    
    override func update(_ plane: PlaneAnchor) async {
        // Pay attention to how this anchor is oriented
        switch plane.alignment {
        case .horizontal:
            break
        case .vertical:
            break
        @unknown default:
            break
        }
        
        switch plane.classification {
        case .wall:
            break
        case .floor:
            break
        case .ceiling:
            break
        case .table:
            break
        case .seat:
            break
        case .window:
            break
        case .door:
            break
        case .notAvailable,
                .undetermined,
                .unknown:
            break
        @unknown default:
            break
        }
    }
    
    override func update(_ mesh: MeshAnchor) async {
    }
    
    override func update(_ image: ImageAnchor) async {
    }
    
    override func update(_ world: WorldAnchor) async {
    }
}
