//
//  ImmersiveView.swift
//  ImmersiveAware
//
//  Created by John Haney on 4/28/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
