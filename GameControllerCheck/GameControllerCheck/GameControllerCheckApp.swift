//
//  GameControllerCheckApp.swift
//  GameControllerCheck
//
//  Created by John Haney on 11/2/25.
//

import SwiftUI

@main
struct GameControllerCheckApp: App {

    @State private var appModel = AppModel()
    @State private var immersion: ImmersionStyle = .mixed
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowResizability(.contentMinSize)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: $immersion, in: .mixed)
        .immersiveEnvironmentBehavior(.coexist)
     }
}
