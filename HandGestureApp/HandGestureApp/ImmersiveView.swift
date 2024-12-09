//
//  ImmersiveView.swift
//  HandGestureApp
//
//  Created by John Haney on 12/8/24.
//

import SwiftUI
import RealityKit
import HandGesture

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    var body: some View {
        RealityView { content in
        }
        .handGesture(
            ClapGesture()
                .onChanged { value in
                    guard appModel.gesture == .clapping else { return }
                    appModel.leftStatus = "clapped!"
                    appModel.rightStatus = "\(Date.now.timeIntervalSinceReferenceDate)"
                }
        )
        .handGesture(
            PunchGesture(hand: .left)
                .onChanged { value in
                    guard appModel.gesture == .punch else { return }
                    appModel.leftStatus = "punch \(value.velocity.magnitude)"
                }
        )
        .handGesture(
            PunchGesture(hand: .right)
                .onChanged { value in
                    guard appModel.gesture == .punch else { return }
                    appModel.rightStatus = "punch \(value.velocity.magnitude)"
                }
        )
        .handGesture(
            FingerGunGesture(hand: .left)
                .onChanged { value in
                    guard appModel.gesture == .fingerGun else { return }
                    appModel.leftStatus = value.thumbDown ? "👉" : "👍"
                }
        )
        .handGesture(
            FingerGunGesture(hand: .right)
                .onChanged { value in
                    guard appModel.gesture == .fingerGun else { return }
                    appModel.rightStatus = value.thumbDown ? "👉" : "👍"
                }
        )
        .handGesture(
            HoldingSphereGesture(hand: .left)
                .onChanged { value in
                    guard appModel.gesture == .sphere else { return }
                    appModel.leftStatus = String(format: "%.3f", value.sphere.radius)
                }
        )
        .handGesture(
            HoldingSphereGesture(hand: .right)
                .onChanged { value in
                    guard appModel.gesture == .sphere else { return }
                    appModel.rightStatus = String(format: "%.3f", value.sphere.radius)
                }
        )
        .handGesture(
            SnapGesture(hand: .left)
                .onChanged { value in
                    print(value.pose == .postSnap ? "L post snap" : "L pre snap")
                    guard appModel.gesture == .snap else { return }
                    switch value.pose {
                    case .noSnap:
                        appModel.leftStatus = "---"
                    case .preSnap:
                        appModel.leftStatus = "🫰"
                    case .postSnap:
                        appModel.leftStatus = "snap"
                    }
                }
        )
        .handGesture(
            SnapGesture(hand: .right)
                .onChanged { value in
                    print(value.pose == .postSnap ? "R post snap" : "R pre snap")
                    guard appModel.gesture == .snap else { return }
                    switch value.pose {
                    case .noSnap:
                        appModel.rightStatus = "---"
                    case .preSnap:
                        appModel.rightStatus = "🫰"
                    case .postSnap:
                        appModel.rightStatus = "snap"
                    }
                }
        )
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

extension SIMD3<Float> {
    var magnitude: Float {
        sqrt(x * x + y * y + z * z)
    }
}
