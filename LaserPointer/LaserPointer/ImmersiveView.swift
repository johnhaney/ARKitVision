//
//  ImmersiveView.swift
//  LaserPointer
//
//  Created by John Haney on 10/26/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARUnderstanding
import GameController

struct ImmersiveView: View {
    let leftAim: Entity = Entity()
    let rightAim: Entity = Entity()
    let colors: [UIColor] = [.green, .yellow, .orange, .red, .purple, .blue, .white, .clear]
    var color: UIColor {
        colors[Self.colorIndex]
    }
    static var colorIndex: Int = 0
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
            content.add(leftAim)
            let laser = ModelEntity(mesh: .generateCylinder(height: 10, radius: 0.0001), materials: [SimpleMaterial(color: .orange, roughness: 1, isMetallic: false)])
            laser.transform = Transform(rotation: .init(angle: .pi/2, axis: [1,0,0]), translation: [0,0,-5])
            leftAim.addChild(laser)
            content.add(rightAim)
        }
        .task {
            for await update in ARUnderstandingAccessoryTrackingProvider(accessoryCategories: [.spatialStylus]).updates {
                switch update.anchor.accessory.source {
                case .device(let device):
                    if let stylus = device as? GCStylus {
                        let button = stylus.input?.buttons[.stylusPrimaryButton]
                        button?.pressedInput.pressedDidChangeHandler = { _, _, pressed in
                            handlePress(pressed)
                        }
                    }
                default:
                    break
                }
                if let aim = try? update.anchor.coordinateSpace(for: .aim, correction: .rendered).convert(value: Transform.identity, to: .worldReference) {
                    leftAim.move(to: aim, relativeTo: nil)
                }
                if let aim = try? update.anchor.coordinateSpace(for: .aim, correction: .none).convert(value: Transform.identity, to: .worldReference) {
                    rightAim.move(to: aim, relativeTo: nil)
                }
            }
        }
    }
    
    func handlePress(_ pressed: Bool) {
        if pressed {
            Self.colorIndex = (Self.colorIndex + 1) % colors.count
            (leftAim.children.first! as! ModelEntity).model?.materials = [SimpleMaterial(color: color, roughness: 1, isMetallic: false)]
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
