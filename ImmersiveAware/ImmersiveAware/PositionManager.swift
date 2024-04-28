//
//  PositionManager.swift
//  ImmersiveAware
//
//  Created by John Haney on 4/28/24.
//

import Foundation
import Spatial
import AVFoundation

class PositionManager: ObservableObject {
    private var state: State = .none
    private var nextState: State?
    
    enum State {
        case none
        case near
        case far
    }
    
    var position: Point3D = .zero {
        didSet {
            updateState()
        }
    }
    private let voice = AVSpeechSynthesizer()
    
    private func updateState() {
        let desiredState: State
        if abs(position.z) <= 500 {
            desiredState = .near
        } else if abs(position.z) >= 3500 {
            desiredState = .far
        } else {
            desiredState = .none
        }
        
        switch (state, desiredState) {
        case (.none, .none),
            (.near, .near),
            (.far, .far):
            break
        case (_, .none):
            state = .none
        case (_, .near):
            if !voice.isSpeaking {
                state = .near
                voice.speak(AVSpeechUtterance(string: "near"))
            } else {
                nextState = .near
            }
        case (_, .far):
            if !voice.isSpeaking {
                state = .far
                voice.speak(AVSpeechUtterance(string: "far"))
            } else {
                nextState = .far
            }
        }
    }
}
