//
//  AppModel.swift
//  GameControllerCheck
//
//  Created by John Haney on 11/2/25.
//

import SwiftUI
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var leftInfo: [(String, String)] = []
    var museInfo: [(String, String)] = []
    var rightInfo: [(String, String)] = []
    var leftSpatialInfo: SpatialControllerInfo? = nil
    var museSpatialInfo: SpatialControllerInfo? = nil
    var rightSpatialInfo: SpatialControllerInfo? = nil
    var leftConnected: Bool = false
    var museConnected: Bool = false
    var rightConnected: Bool = false
}

struct SpatialControllerInfo {
    let transform: Transform
    let velocity: SIMD3<Float>
    let angularVelocity: SIMD3<Float>
}

