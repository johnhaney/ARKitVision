//
//  ImmersiveView.swift
//  GameControllerCheck
//
//  Created by John Haney on 11/2/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GameController
import ARKit

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
        .task {
            for await update in ARUnderstandingAccessoryTrackingProvider(accessoryCategories: [.spatialStylus, .spatialControllers]).updates {
                switch update.anchor.accessory.source {
                case .device(let device):
                    switch device.productCategory {
                    case GCProductCategorySpatialStylus:
                        appModel.museSpatialInfo = update.anchor.spatialInfo
                    case GCProductCategorySpatialController:
                        switch update.anchor.heldChirality {
                        case .left:
                            appModel.leftSpatialInfo = update.anchor.spatialInfo
                        case .right:
                            appModel.rightSpatialInfo = update.anchor.spatialInfo
                        default:
                            break
                        }
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
    }
}

extension AccessoryAnchor {
    var spatialInfo: SpatialControllerInfo {
        SpatialControllerInfo(transform: Transform(matrix: originFromAnchorTransform),
                              velocity: velocity,
                              angularVelocity: angularVelocity)
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
