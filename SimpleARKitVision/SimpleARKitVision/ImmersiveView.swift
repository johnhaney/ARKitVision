//
//  ImmersiveView.swift
//  SimpleARKitVision
//
//  Created by John Haney (Lextech) on 3/31/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARUnderstanding

struct ImmersiveView: View {
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        RealityView { content in
        }
        .task {
            for await anchor in ARUnderstanding.handUpdates {
                switch anchor.chirality {
                case .left:
                    // TODO: handle left hand update
                    break
                case .right:
                    // TODO: handle right hand update
                    break
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
