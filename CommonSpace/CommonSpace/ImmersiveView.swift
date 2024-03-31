//
//  ImmersiveView.swift
//  CommonSpace
//
//  Created by John Haney on 3/31/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(CommonSpaceViewModel.self) var model
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        } update: { content in
            // TODO: use model.homeEntity as the common frame of reference for the world. Look for an entity named "home" to verify that the home marker has indeed been found and you are ready to go
        }
        .task {
            do {
                if model.dataProvidersAreSupported && model.isReadyToRun {
                    try await model.runSession()
                } else {
                    await dismissImmersiveSpace()
                }
            } catch {
                logger.error("Failed to start session: \(error)")
                await dismissImmersiveSpace()
                // TODO: You should also show the user that something went wrong, maybe open a new window.
            }
        }
        .task {
            await model.processUpdates()
        }
        .task {
            await model.monitorSessionEvents()
        }
        .task(priority: .low) {
            await model.processLowUpdates()
        }
    }
}
