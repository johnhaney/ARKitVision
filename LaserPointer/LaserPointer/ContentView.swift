//
//  ContentView.swift
//  LaserPointer
//
//  Created by John Haney on 10/26/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Hello, welcome to laser pointer. Connect a Logitech Muse and Show the Immersive Space to see the pointer.")

            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
