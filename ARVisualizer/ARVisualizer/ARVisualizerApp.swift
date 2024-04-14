//
//  ARVisualizerApp.swift
//  ARVisualizer
//
//  Created by John Haney on 4/14/24.
//

import SwiftUI

@main
struct ARVisualizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
