//
//  HapticManager.swift
//  SpinifyWatch Watch App
//
//  Created by Muslim Mirzajonov on 18/05/26.
//

import WatchKit

class HapticManager {
    static let shared = HapticManager()
    private init() {}

    func playTick() {
        WKInterfaceDevice.current().play(.click)
    }

    func playFinalReveal() {
        WKInterfaceDevice.current().play(.success)
    }
}
