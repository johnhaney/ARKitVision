//
//  AppModel.swift
//  HandGestureApp
//
//  Created by John Haney on 12/8/24.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    var gesture: HandGestures = .clapping
    var leftStatus: String = "---"
    var rightStatus: String = "---"

    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
