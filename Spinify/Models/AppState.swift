//
//  State.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import Foundation

struct AppState {
    enum Screen { case setup, spin }
    var screen: Screen = .setup
    var minValue: Double = 1
    var maxValue: Double = 1000
    var currentNumber: Int? = nil
    var isSpinning = false
}
