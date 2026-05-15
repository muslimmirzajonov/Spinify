//
//  SpinifyViewModel.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import SwiftUI
import Combine

@MainActor
final class SpinifyViewModel: ObservableObject {
    @Published var state = AppState()
    @Published var bgColor: Color = .init(hex: "#0f0c29")
    @Published var numberScale: CGFloat = 1.0
    @Published var numberOpacity: Double = 1.0

    private let bgPalette: [Color] = [
        .init(hex: "#0f0c29"), .init(hex: "#1a1a2e"), .init(hex: "#16213e"),
        .init(hex: "#2c1654"), .init(hex: "#1e0a3c"), .init(hex: "#2d1b69"),
        .init(hex: "#0a2e1a"), .init(hex: "#0f3028"), .init(hex: "#0a2a2a"),
        .init(hex: "#0f2d35"), .init(hex: "#2a0a0a"), .init(hex: "#2e1015"),
        .init(hex: "#1a1040"), .init(hex: "#1d1550"), .init(hex: "#0e0b2e"),
    ]
    private var lastBgColor: Color = .init(hex: "#0f0c29")
    private var spinTask: Task<Void, Never>?

    private func nextBgColor() -> Color {
        let others = bgPalette.filter { $0 != lastBgColor }
        let next = others.randomElement() ?? bgPalette[0]
        lastBgColor = next
        return next
    }

    func proceed() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            state.screen = .spin
        }
    }

    func goBack() {
        spinTask?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            state.screen = .setup
            state.currentNumber = nil
            state.isSpinning = false
        }
    }

    func spin() {
        guard !state.isSpinning else { return }
        guard Int(state.minValue) < Int(state.maxValue) else { return }
        state.isSpinning = true

        let finalNumber = Int.random(in: Int(state.minValue)...Int(state.maxValue))

        let tickDelays: [UInt64] = [
            90, 75, 60, 45, 35, 28,
            28, 35, 50, 70, 95, 120,
            150, 190, 240
        ]
        let totalTicks = tickDelays.count

        spinTask = Task {
            for tick in 0..<totalTicks {
                guard !Task.isCancelled else { return }

                let delayMs = tickDelays[tick]
                try? await Task.sleep(nanoseconds: delayMs * 1_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(.easeOut(duration: 0.05)) {
                    numberOpacity = 0.15
                    numberScale = 0.82
                }
                try? await Task.sleep(nanoseconds: 35_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(.spring(response: 0.18, dampingFraction: 0.65)) {
                    state.currentNumber = Int.random(in: Int(state.minValue)...Int(state.maxValue))
                    numberOpacity = 1.0
                    numberScale = 1.0
                }
                HapticManager.shared.playTick()

                withAnimation(.easeInOut(duration: 0.5)) {
                    bgColor = nextBgColor()
                }
            }

            withAnimation(.easeOut(duration: 0.1)) {
                numberOpacity = 0.0
                numberScale = 0.5
            }
            try? await Task.sleep(nanoseconds: 100_000_000)

            withAnimation(.spring(response: 0.4, dampingFraction: 0.45)) {
                state.currentNumber = finalNumber
                numberOpacity = 1.0
                numberScale = 1.3
            }
            HapticManager.shared.playFinalReveal()
            try? await Task.sleep(nanoseconds: 220_000_000)

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                numberScale = 1.0
            }

            state.isSpinning = false
        }
    }
}
