//
//  HapticManager.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import CoreHaptics
import SwiftUI

final class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private var isEngineRunning = false

    private init() {
        setupEngine()
    }

    private func setupEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let e = try CHHapticEngine()
            e.stoppedHandler = { [weak self] reason in
                self?.isEngineRunning = false
                self?.restartEngine()
            }
            e.resetHandler = { [weak self] in
                self?.isEngineRunning = false
                self?.restartEngine()
            }
            engine = e
            startEngine()
        } catch {}
    }

    private func startEngine() {
        guard let engine, !isEngineRunning else { return }
        do {
            try engine.start()
            isEngineRunning = true
        } catch {}
    }

    private func restartEngine() {
        guard let engine else { return }
        engine.start { [weak self] error in
            if error == nil {
                self?.isEngineRunning = true
            }
        }
    }

    private func ensureRunning() {
        if !isEngineRunning {
            restartEngine()
        }
    }

    func playTick() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }
        ensureRunning()
        guard let engine else { return }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
            ],
            relativeTime: 0
        )
        play(events: [event], engine: engine)
    }

    func playFinalReveal() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            let g = UINotificationFeedbackGenerator()
            g.notificationOccurred(.success)
            return
        }
        ensureRunning()
        guard let engine else { return }
        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0.10
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.22
            )
        ]
        play(events: events, engine: engine)
    }

    private func play(events: [CHHapticEvent], engine: CHHapticEngine) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            restartEngine()
        }
    }
}
