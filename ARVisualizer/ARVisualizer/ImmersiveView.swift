//
//  ImmersiveView.swift
//  ARVisualizer
//
//  Created by John Haney on 4/14/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARUnderstanding
import ARKit

struct ImmersiveView: View {
    @State var rootEntity: Entity = Entity()
    @State var visualizations: [UUID: Entity] = [:]
    var body: some View {
        RealityView { content in
            content.add(rootEntity)
        }
        .task {
            for await anchor in ARUnderstanding(providers: [
                .hands,
                .planes,
                .meshes,
                .verticalPlanes,
                .device,
                .image(resourceGroupName: "AR Resources"),
                .world,
            ]).anchorUpdates {
                switch anchor.event {
                case .added:
                    let entity = anchor.visualization
                    rootEntity.addChild(entity)
                    visualizations[anchor.id] = entity
                case .updated:
                    guard let entity = visualizations[anchor.id]
                    else {
                        let entity = anchor.visualization
                        rootEntity.addChild(entity)
                        visualizations[anchor.id] = entity
                        return
                    }
                    entity.components.remove(OpacityComponent.self)
                    anchor.update(visualization: entity)
                case .removed:
                    guard let entity = visualizations[anchor.id]
                    else { return }
                    entity.components.set(OpacityComponent(opacity: 0))
                }
            }
            for child in rootEntity.children {
                child.removeFromParent()
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
