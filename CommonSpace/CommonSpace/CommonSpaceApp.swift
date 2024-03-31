//
//  CommonSpaceApp.swift
//  CommonSpace
//
//  Created by John Haney on 3/31/24.
//

import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.appsyoucanmake.SimpleARKitVision", category: "general")

@main
struct CommonSpaceApp: App {
    @State private var commonModel: CommonSpaceViewModel
    
    init() {
        commonModel = CommonSpaceViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(commonModel)
        }
    }
}
