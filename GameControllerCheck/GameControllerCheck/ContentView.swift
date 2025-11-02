//
//  ContentView.swift
//  GameControllerCheck
//
//  Created by John Haney on 11/2/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GameController
import ARKit

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    @State var stylus: GCDevicePhysicalInputState? = nil
    
    @ViewBuilder
    func infoView(_ spatial: SpatialControllerInfo?, _ info: [(String, String)]) -> some View {
        if let spatial {
            HStack {
                Text(spatial.transform.translation.x, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.transform.translation.y, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.transform.translation.z, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
            }
            HStack {
                Text(spatial.transform.rotation.angle, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.transform.rotation.axis.x, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.transform.rotation.axis.y, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.transform.rotation.axis.z, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
            }
            HStack {
                Text(spatial.velocity.x, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.velocity.y, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.velocity.z, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
            }
            HStack {
                Text(spatial.angularVelocity.x, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.angularVelocity.y, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
                Text(spatial.angularVelocity.z, format: .number.rounded(rule: .toNearestOrAwayFromZero, increment: 0.01))
            }
        }
        Grid {
            ForEach(info.enumerated(), id: \.offset) { item in
                GridRow {
                    Text(item.element.0)
                    Text(item.element.1)
                }
            }
        }
    }

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                VStack {
                    HStack {
                        Text("Left PSVR2 Controller")
                        if !appModel.leftConnected {
                            Text("(Disconnected)")
                        }
                    }
                    infoView(appModel.leftSpatialInfo, appModel.leftInfo)
                        .monospacedDigit()
                }
                VStack {
                    HStack {
                        Text("Logitech Muse")
                        if !appModel.museConnected {
                            Text("(Disconnected)")
                        }
                    }
                    infoView(appModel.museSpatialInfo, appModel.museInfo)
                        .monospacedDigit()
                }
                VStack {
                    HStack {
                        Text("Right PSVR2 Controller")
                        if !appModel.rightConnected {
                            Text("(Disconnected)")
                        }
                    }
                    infoView(appModel.rightSpatialInfo, appModel.rightInfo)
                        .monospacedDigit()
                }
            }
            ToggleImmersiveSpaceButton()
        }
        .padding()
        .task {
            while true {
                try? await Task.sleep(for: .milliseconds(100))
                var foundLeft = false
                var foundMuse = false
                var foundRight = false
                for controller in GCController.controllers() {
                    let controllerState = controller.input.capture()
                    var info: [(String, String)] = []
                    for axis in controllerState.axes {
                        info.append(
                            ("Axis \(axis.description)",
                             "\(axis.absoluteInput?.value)")
                        )
                    }
                    for button in controllerState.buttons {
                        info.append(
                            ("Button \(button.description) Force",
                             "\(button.forceInput?.value)")
                        )
                        info.append(
                            ("Button \(button.description) Pressed",
                             "\(button.pressedInput.value)")
                        )
                        info.append(
                            ("Button \(button.description) Touched",
                             "\(button.touchedInput?.isTouched)")
                        )
                    }
                    for dpad in controllerState.dpads {
                        info.append(
                            ("Dpad \(dpad.description) ",
                             "(\(dpad.xyAxes.value.x), \(dpad.xyAxes.value.y))")
                        )
                    }
                    if let device = controller.input.device,
                       device.productCategory == GCProductCategorySpatialController,
                       let accessory = try? await Accessory(device: device) {
                        switch accessory.inherentChirality {
                        case .right:
                            appModel.rightInfo = info
                            foundRight = true
                        case .left:
                            appModel.leftInfo = info
                            foundLeft = true
                        case .unspecified:
                            break
                        @unknown default:
                            break
                        }
                    }
                }
                for stylus in GCStylus.styli {
                    if let museState = stylus.input?.capture() {
                        var info: [(String, String)] = []
                        for axis in museState.axes {
                            info.append(
                                ("Axis \(axis.description)",
                                 "\(axis.absoluteInput?.value)")
                            )
                        }
                        for button in museState.buttons {
                            info.append(
                                ("Button \(button.description) Force",
                                 "\(button.forceInput?.value)")
                            )
                            info.append(
                                ("Button \(button.description) Pressed",
                                 "\(button.pressedInput.value)")
                            )
                            info.append(
                                ("Button \(button.description) Touched",
                                 "\(button.touchedInput?.isTouched)")
                            )
                        }
                        for dpad in museState.dpads {
                            info.append(
                                ("Dpad \(dpad.description) ",
                                 "(\(dpad.xyAxes.value.x), \(dpad.xyAxes.value.y))")
                            )
                        }
                        appModel.museInfo = info
                        foundMuse = true
                    }
                }
                appModel.leftConnected = foundLeft
                appModel.museConnected = foundMuse
                appModel.rightConnected = foundRight
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

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
