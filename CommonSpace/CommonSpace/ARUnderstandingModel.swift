//
//  ARUnderstandingModel.swift
//  SimpleARKitVision
//
//  Created by John Haney on 3/31/24.
//

import ARKit
import RealityKit

@Observable
@MainActor
class ARUnderstandingModel {
    let session = ARKitSession()
    private(set) var providers: [ARProvider]
    var errorState = false
    
    var contentEntity = Entity()
    var homeEntity = Entity()

    init(providers: [ARProvider]) {
        self.providers = providers
    }
    
    func runSession() async throws {
        try await session.run(providers.map(\.dataProvider))
    }
    
    func setupContentEntity() -> Entity {
        contentEntity.addChild(homeEntity)
        return contentEntity
    }
    
    var dataProvidersAreSupported: Bool {
        return providers.map(\.isSupported).reduce(true, { $0 && $1 })
    }
    
    var isReadyToRun: Bool {
        return providers.map(\.isReadyToRun).reduce(true, { $0 && $1 })
    }
    
    func processUpdates() async {
        for provider in providers {
            if case .meshes = provider {
            } else {
                Task.detached {
                    await provider.processUpdates(model: self)
                }
            }
        }
    }
    
    func processLowUpdates() async {
        for provider in providers {
            if case .meshes = provider {
                await provider.processUpdates(model: self)
            }
        }
    }
    
    func monitorSessionEvents() async {
        for await event in session.events {
            switch event {
            case .authorizationChanged(type: _, status: let status):
                logger.info("Authorization changed to: \(status)")
                
                if status == .denied {
                    errorState = true
                }
            case .dataProviderStateChanged(dataProviders: let providers, newState: let state, error: let error):
                logger.info("Data provider changed: \(providers), \(state)")
                if let error {
                    logger.error("Data provider reached an error state: \(error)")
                    errorState = true
                }
            @unknown default:
                fatalError("Unhandled new event type \(event)")
            }
        }
    }
    
    func processMeshUpdates(_ mesh: SceneReconstructionProvider) async {
        for await update in mesh.anchorUpdates {
            await self.update(update.anchor)
        }
    }
    
    func processHandUpdates(_ handTracking: HandTrackingProvider) async {
        for await update in handTracking.anchorUpdates {
            await self.update(update.anchor)
        }
    }
    
    func processImageUpdates(_ imageTracking: ImageTrackingProvider) async {
        for await update in imageTracking.anchorUpdates {
            await self.update(update.anchor)
        }
    }
    
    func processPlaneUpdates(_ planeDetection: PlaneDetectionProvider) async {
        for await update in planeDetection.anchorUpdates {
            await self.update(update.anchor)
        }
    }
    
    func processWorldUpdates(_ worldTracking: WorldTrackingProvider) async {
        for await update in worldTracking.anchorUpdates {
            await self.update(update.anchor)
        }
    }
    
    func update(_ anchor: MeshAnchor) async {}
    func update(_ anchor: HandAnchor) async {}
    func update(_ anchor: ImageAnchor) async {}
    func update(_ anchor: PlaneAnchor) async {}
    func update(_ anchor: WorldAnchor) async {}
}

@MainActor
enum ARProvider {
    case hands(HandTrackingProvider)
    case meshes(SceneReconstructionProvider)
    case planes(PlaneDetectionProvider)
    case image(ImageTrackingProvider)
    case world(WorldTrackingProvider)
    
    var isReadyToRun: Bool {
        switch self {
        case .hands(let handTrackingProvider):
            return handTrackingProvider.state == .initialized
        case .meshes(let sceneReconstructionProvider):
            return sceneReconstructionProvider.state == .initialized
        case .planes(let planeDetectionProvider):
            return planeDetectionProvider.state == .initialized
        case .image(let imageTrackingProvider):
            return imageTrackingProvider.state == .initialized
        case .world(let worldTrackingProvider):
            return worldTrackingProvider.state == .initialized
        }
    }
    
    var isSupported: Bool {
        switch self {
        case .hands(_):
            return HandTrackingProvider.isSupported
        case .meshes(_):
            return SceneReconstructionProvider.isSupported
        case .planes(_):
            return PlaneDetectionProvider.isSupported
        case .image(_):
            return ImageTrackingProvider.isSupported
        case .world(_):
            return WorldTrackingProvider.isSupported
        }
    }
    
    var dataProvider: DataProvider {
        switch self {
        case .hands(let handTrackingProvider):
            return handTrackingProvider
        case .meshes(let sceneReconstructionProvider):
            return sceneReconstructionProvider
        case .planes(let planeDetectionProvider):
            return planeDetectionProvider
        case .image(let imageTrackingProvider):
            return imageTrackingProvider
        case .world(let worldTrackingProvider):
            return worldTrackingProvider
        }
    }
    
    @MainActor
    func processUpdates(model: ARUnderstandingModel) async {
        switch self {
        case .hands(let handTracking):
            await model.processHandUpdates(handTracking)
        case .meshes(let mesh):
            await model.processMeshUpdates(mesh)
        case .planes(let provider):
            await model.processPlaneUpdates(provider)
        case .image(let provider):
            await model.processImageUpdates(provider)
        case .world(let world):
            await model.processWorldUpdates(world)
        }
    }
}
