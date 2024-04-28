//
//  ContentView.swift
//  ImmersiveAware
//
//  Created by John Haney on 4/28/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @ObservedObject var positionManager: PositionManager

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            Text("Hello, world!")
            
            GeometryReader3D { g in
                VStack(alignment: .leading) {
                    Text("\(g.frame(in: NamedCoordinateSpace.immersiveSpace).min)")
                    Text("\(g.frame(in: NamedCoordinateSpace.immersiveSpace).center)")
                    Text("\(g.frame(in: NamedCoordinateSpace.immersiveSpace).max)")
                    Text(" ")
                    Text("\(g.frame(in: NamedCoordinateSpace.immersiveSpace).size)")
                }
                .monospacedDigit()
                .onChange(of: g.frame(in: NamedCoordinateSpace.immersiveSpace).center, { oldValue, newValue in
                    if immersiveSpaceIsShown {
                        positionManager.position = newValue
                    }
                })
            }

            Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                .font(.title)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}
