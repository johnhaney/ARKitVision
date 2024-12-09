//
//  ContentView.swift
//  HandGestureApp
//
//  Created by John Haney on 12/8/24.
//

import SwiftUI
import RealityKit
import HandGesture

enum HandGestures: String, Hashable, Identifiable, CaseIterable {
    case clapping = "Clapping"
    case fingerGun = "Finger Guns"
    case sphere = "Holding Sphere"
    case punch = "Punching"
    case snap = "Snap"
    
    var id: String { rawValue }
}

extension HandGestures {
    var text: String {
        switch self {
        case .clapping:
            "👏"
        case .fingerGun:
            "👉👉"
        case .sphere:
            "🤲"
        case .punch:
            "👊"
        case .snap:
            "🫰"
        }
    }
}

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    var body: some View {
        HStack {
            VStack {
                ForEach(HandGestures.allCases) { gesture in
                    Toggle(gesture.rawValue, isOn: Binding(get: {
                        appModel.gesture == gesture
                    }, set: { isOn in
                        if isOn {
                            appModel.gesture = gesture
                        }
                    }))
                }
            }
            VStack {
                gestureCard(appModel.gesture)
                
                ToggleImmersiveSpaceButton()
            }
        }
        .padding()
    }
    
    @ViewBuilder func gestureCard(_ gesture: HandGestures) -> some View {
        VStack {
            Spacer()
            Text(gesture.text)
                .font(.largeTitle)
            HStack {
                Spacer()
                Text(appModel.leftStatus)
                    .monospacedDigit()
                Text(appModel.rightStatus)
                    .monospacedDigit()
                Spacer()
            }
            Spacer()
        }
        .padding(30)
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
