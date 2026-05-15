//
//  HapticManager.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import CoreHaptics

final class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?

    private init() {}

    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {}
    }

    func playTick() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine else { return }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0
        )
        play(events: [event], engine: engine)
    }

    func playFinalReveal() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine else { return }
        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0.12
            )
        ]
        play(events: events, engine: engine)
    }

    private func play(events: [CHHapticEvent], engine: CHHapticEngine) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {}
    }
}
