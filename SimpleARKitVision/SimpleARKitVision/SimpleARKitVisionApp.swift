//
//  SimpleARKitVisionApp.swift
//  SimpleARKitVision
//
//  Created by John Haney (Lextech) on 3/31/24.
//

import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.appsyoucanmake.SimpleARKitVision", category: "general")

@main
struct SimpleARKitVisionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
