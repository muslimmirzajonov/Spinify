//
//  SpinifyWidget.swift
//  SpinifyWidget
//
//  Created by Muslim Mirzajonov on 18/05/26.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Spin App Intent

struct SpinIntent: AppIntent {
    static var title: LocalizedStringResource { "Spin" }

    func perform() async throws -> some IntentResult {
        let shared = UserDefaults(suiteName: "group.app.Spinify")
        let minValue = shared?.integer(forKey: "minValue") ?? 1
        let maxValue: Int = {
            if let saved = shared?.object(forKey: "maxValue") as? Int { return saved }
            return 1000
        }()
        let safeMax = max(minValue + 1, maxValue)
        let result = Int.random(in: minValue...safeMax)
        shared?.set(result, forKey: "lastNumber")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Entry

struct SpinifyEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let lastNumber: Int?
    let minValue: Int
    let maxValue: Int
}

// MARK: - Provider

struct Provider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> SpinifyEntry {
        SpinifyEntry(date: .now, configuration: ConfigurationAppIntent(), lastNumber: 42, minValue: 1, maxValue: 100)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SpinifyEntry {
        makeEntry(configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SpinifyEntry> {
        let entry = makeEntry(configuration: configuration)
        return Timeline(entries: [entry], policy: .never)
    }

    private func makeEntry(configuration: ConfigurationAppIntent) -> SpinifyEntry {
        let shared = UserDefaults(suiteName: "group.app.Spinify")
        let lastNumber = shared?.object(forKey: "lastNumber") as? Int

        // Appda saqlangan range — agar yo'q bo'lsa default 1...1000
        let minValue: Int = shared?.object(forKey: "minValue") as? Int ?? 1
        let maxValue: Int = shared?.object(forKey: "maxValue") as? Int ?? 1000

        return SpinifyEntry(
            date: .now,
            configuration: configuration,
            lastNumber: lastNumber,
            minValue: minValue,
            maxValue: maxValue
        )
    }
}

// MARK: - Background

private let widgetBg = Color(red: 0.424, green: 0.0, blue: 1.0)

private func localizedSpin() -> String {
    let code = UserDefaults(suiteName: "group.app.Spinify")?.string(forKey: "spinify_lang_code") ?? "en"
    return L10n.t("lets_spin", code: code)
}

// MARK: - Home Screen Small

struct HomeSmallWidgetView: View {
    var entry: SpinifyEntry

    var body: some View {
        VStack(spacing: 2) {
            Text("SPINIFY")
                .font(.system(size: 9, weight: .bold))
                .tracking(2.5)
                .foregroundColor(.white.opacity(0.45))

            Spacer()

            if let number = entry.lastNumber {
                Text("\(number)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
            } else {
                Text("–")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }

            Text("\(entry.minValue) – \(entry.maxValue)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.38))

            Spacer()

            // Frosted pill tugma
            Button(intent: SpinIntent()) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .font(.system(size: 11, weight: .bold))
                    Text(localizedSpin())
                        .font(.system(size: 11, weight: .bold))
                        .lineLimit(1)
                        .fixedSize()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.white.opacity(0.18))
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.28), lineWidth: 1)
                )
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .containerBackground(widgetBg, for: .widget)
    }
}

// MARK: - Home Screen Medium

struct HomeMediumWidgetView: View {
    var entry: SpinifyEntry

    var body: some View {
        HStack(alignment: .center, spacing: 0) {

            // Chap: info blok
            VStack(alignment: .leading, spacing: 0) {
                Text("SPINIFY")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2.5)
                    .foregroundColor(.white.opacity(0.45))

                Spacer()

                if let number = entry.lastNumber {
                    Text("\(number)")
                        .font(.system(size: 68, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.35)
                        .lineLimit(1)
                } else {
                    Text("–")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }

                Spacer()

                Text("\(entry.minValue) – \(entry.maxValue)")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(.white.opacity(0.38))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // O'ng: frosted doira tugma
            Button(intent: SpinIntent()) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 1.5)
                        )
                        .frame(width: 90, height: 90)

                    VStack(spacing: 4) {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                        Text(localizedSpin())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: 64)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .containerBackground(widgetBg, for: .widget)
    }
}

// MARK: - Lock Screen

struct LockScreenWidgetView: View {
    var entry: SpinifyEntry

    var body: some View {
        VStack(spacing: 2) {
            if let number = entry.lastNumber {
                Text("\(number)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
            } else {
                Text("–")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .opacity(0.5)
            }
            Text("\(entry.minValue)–\(entry.maxValue)")
                .font(.system(size: 10, weight: .semibold))
                .opacity(0.6)
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Entry View

struct SpinifyWidgetEntryView: View {
    var entry: SpinifyEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            HomeSmallWidgetView(entry: entry)
        case .systemMedium:
            HomeMediumWidgetView(entry: entry)
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            LockScreenWidgetView(entry: entry)
        default:
            HomeSmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget

struct SpinifyWidget: Widget {
    let kind = "SpinifyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            SpinifyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Spinify")
        .description("Raqam chiqaring — app ochmasdan")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Preview

extension ConfigurationAppIntent {
    fileprivate static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.minValue = 1
        intent.maxValue = 100
        return intent
    }
}

#Preview(as: .systemSmall) {
    SpinifyWidget()
} timeline: {
    SpinifyEntry(date: .now, configuration: .preview, lastNumber: nil, minValue: 1, maxValue: 100)
    SpinifyEntry(date: .now, configuration: .preview, lastNumber: 73, minValue: 1, maxValue: 100)
}

#Preview(as: .systemMedium) {
    SpinifyWidget()
} timeline: {
    SpinifyEntry(date: .now, configuration: .preview, lastNumber: 42, minValue: 1, maxValue: 100)
}

#Preview(as: .accessoryCircular) {
    SpinifyWidget()
} timeline: {
    SpinifyEntry(date: .now, configuration: .preview, lastNumber: 7, minValue: 1, maxValue: 100)
}
