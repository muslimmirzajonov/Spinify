//
//  SpinifyViewModel.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

#if os(iOS)
import UIKit
#endif
import SwiftUI
import WidgetKit
import Combine

@MainActor
final class SpinifyViewModel: ObservableObject {
    @Published var state = AppState()
    @Published var bgColor: Color = .init(hex: "#6C00FF")
    @Published var numberScale: CGFloat = 1.0
    @Published var numberOpacity: Double = 1.0

    @Published var langCode: String = {
        if let saved = UserDefaults(suiteName: "group.app.Spinify")?
            .string(forKey: "spinify_lang_code"),
           L10n.supported.contains(where: { $0.code == saved }) {
            return saved
        }
        if let saved = UserDefaults.standard.string(forKey: "spinify_lang_code"),
           L10n.supported.contains(where: { $0.code == saved }) {
            return saved
        }
        return L10n.resolvedCode()
    }()
    
    init() {
        let shared = UserDefaults(suiteName: "group.app.Spinify")
        
        let code = UserDefaults.standard.string(forKey: "spinify_lang_code") ?? L10n.resolvedCode()
        shared?.set(code, forKey: "spinify_lang_code")
    }

    private let bgPalette: [Color] = [
        .init(hex: "#6C00FF"), // electric violet
        .init(hex: "#0066FF"), // vivid blue
        .init(hex: "#00C2FF"), // cyan
        .init(hex: "#FF006E"), // hot pink
        .init(hex: "#FF4500"), // orange red
        .init(hex: "#FF9500"), // amber
        .init(hex: "#00D084"), // emerald
        .init(hex: "#00B4AA"), // teal
        .init(hex: "#8B5CF6"), // soft purple
        .init(hex: "#EC4899"), // rose
        .init(hex: "#F59E0B"), // gold
        .init(hex: "#10B981"), // green
        .init(hex: "#3B82F6"), // blue
        .init(hex: "#EF4444"), // red
        .init(hex: "#A855F7"), // purple
        .init(hex: "#14B8A6"), // teal-green
    ]
    private var lastBgColor: Color = .init(hex: "#6C00FF")
    private var spinTask: Task<Void, Never>?

    func t(_ key: String) -> String { L10n.t(key, code: langCode) }

    private func nextBgColor() -> Color {
        let others = bgPalette.filter { $0 != lastBgColor }
        let next = others.randomElement() ?? bgPalette[0]
        lastBgColor = next
        return next
    }

    func openLanguageSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
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
            200, 160, 120, 90, 65, 48, 38, 32, 28, 28,
            28, 28, 32, 38, 48,
            60, 80, 105, 135, 170, 210, 260
        ]
        let totalTicks = tickDelays.count

        spinTask = Task {
            for tick in 0..<totalTicks {
                guard !Task.isCancelled else { return }

                let delayMs = tickDelays[tick]

                withAnimation(.easeIn(duration: Double(delayMs) * 0.0004)) {
                    numberOpacity = 0.0
                    numberScale = 0.88
                }

                try? await Task.sleep(nanoseconds: (delayMs / 2) * 1_000_000)
                guard !Task.isCancelled else { return }

                state.currentNumber = Int.random(in: Int(state.minValue)...Int(state.maxValue))

                withAnimation(.easeOut(duration: Double(delayMs) * 0.0004)) {
                    numberOpacity = 1.0
                    numberScale = 1.0
                }

                HapticManager.shared.playTick()

                if tick % 3 == 0 {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        bgColor = nextBgColor()
                    }
                }

                try? await Task.sleep(nanoseconds: (delayMs / 2) * 1_000_000)
            }

            withAnimation(.easeIn(duration: 0.12)) {
                numberOpacity = 0.0
                numberScale = 0.7
            }
            try? await Task.sleep(nanoseconds: 130_000_000)

#if os(iOS)
            let shared = UserDefaults(suiteName: "group.app.Spinify")
            shared?.set(finalNumber, forKey: "lastNumber")
            shared?.set(Int(state.minValue), forKey: "minValue")
            shared?.set(Int(state.maxValue), forKey: "maxValue")
            // Rang saqlash
            if let components = UIColor(bgColor).cgColor.components, components.count >= 3 {
                shared?.set(components[0], forKey: "bgR")
                shared?.set(components[1], forKey: "bgG")
                shared?.set(components[2], forKey: "bgB")
            }
            WidgetCenter.shared.reloadAllTimelines()
#endif
            
            state.currentNumber = finalNumber
            HapticManager.shared.playFinalReveal()

            withAnimation(.spring(response: 0.5, dampingFraction: 0.42)) {
                numberOpacity = 1.0
                numberScale = 1.35
            }

            try? await Task.sleep(nanoseconds: 280_000_000)

            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                numberScale = 1.0
            }

            state.isSpinning = false
        }
    }
}
