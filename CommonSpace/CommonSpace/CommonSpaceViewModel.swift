//
//  CommonSpaceViewModel.swift
//  CommonSpace
//
//  Created by John Haney on 3/31/24.
//

import ARKit
import RealityKit
//import Spatial

@Observable
@MainActor
class CommonSpaceViewModel: ARUnderstandingModel {
    let imageTracking = ImageTrackingProvider(
        referenceImages: ReferenceImage.loadReferenceImages(inGroupNamed: "CardDeck20")
    )
    
    var imageAnchors: [UUID: ImageAnchor] = [:]
    var imageAnchorsByName: [String: ImageAnchor] = [:]
    var entityMap: [UUID: Entity] = [:]
    var home: UUID = UUID()

    init() {
        super.init(providers: [.image(imageTracking)])
    }
    
    override func update(_ anchor: ImageAnchor) async {
        if imageAnchors[anchor.id] == nil {
            do {
                // TODO: you could just make an Entity() if you don't want to have a visible Sphere on the image
                let entity = ModelEntity(mesh: .generateSphere(radius: 0.025))
                entity.name = anchor.id.uuidString
                entityMap[anchor.id] = entity
                contentEntity.addChild(entity)
            }
            self.imageAnchors[anchor.id] = anchor
            imageAnchorsByName[anchor.referenceImage.name ?? "NAME"] = anchor
            checkHome()
        }
        
        if anchor.isTracked {
            entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
        }
    }
    
    func checkHome() {
        // only set the home once
        guard entityMap[home] == nil else { return }
        
        if let one = imageAnchorsByName["IMG_4108"] {
            let oneTransform = one.originFromAnchorTransform
            var position = Transform(matrix: oneTransform)
            position.translation = SIMD3<Float>(x: position.translation.x, y: 0, z: position.translation.z)
            
            let base = AnchorEntity(world: position.matrix)
            
            let rotationOne = Entity()
            rotationOne.transform = Transform(rotation: simd_quatf(angle: .pi, axis: SIMD3<Float>(x: 0, y: 1, z: 0)))
            
            let rotationTwo = Entity()
            rotationTwo.transform = Transform(rotation: simd_quatf(angle: .pi/2, axis: SIMD3<Float>(x: 1, y: 0, z: 0)))
            
            entityMap[one.id]?.addChild(rotationOne)
            rotationOne.addChild(rotationTwo)
            
            // TODO: you could just make an Entity() if you don't want to have a visible Sphere on the image
            let homeEntity = ModelEntity(mesh: .generateSphere(radius: 0.025))
            homeEntity.name = "home"
            entityMap[home] = homeEntity
            rotationTwo.addChild(homeEntity)
            rotationTwo.addChild(self.homeEntity)
        }
    }
}
