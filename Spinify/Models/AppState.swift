//
//  State.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import Foundation

struct AppState: Equatable {
    var minValue: Double = 1
    var maxValue: Double = 100
    var currentNumber: Int? = nil
    var isSpinning: Bool = false
    var screen: Screen = .setup

    enum Screen { case setup, spin }
}
