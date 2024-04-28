//
//  ImmersiveAwareApp.swift
//  ImmersiveAware
//
//  Created by John Haney on 4/28/24.
//

import SwiftUI

@main
struct ImmersiveAwareApp: App {
    @State var positionManager = PositionManager()
    var body: some Scene {
        WindowGroup {
            ContentView(positionManager: positionManager)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
