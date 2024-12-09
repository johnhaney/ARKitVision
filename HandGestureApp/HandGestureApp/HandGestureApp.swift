//
//  HandGestureApp.swift
//  HandGestureApp
//
//  Created by John Haney on 12/8/24.
//

import SwiftUI

@main
struct HandGestureApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

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
        .immersionStyle(selection: .constant(.progressive), in: .mixed, .progressive, .full)
     }
}
