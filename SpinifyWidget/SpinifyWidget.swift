//
//  SpinifyWidget.swift
//  SpinifyWidget
//
//  Created by Muslim Mirzajonov on 18/05/26.
//

import WidgetKit
import SwiftUI
import AppIntents

struct SpinIntent: AppIntent {
    static var title: LocalizedStringResource { "Spin" }

    func perform() async throws -> some IntentResult {
        let shared = UserDefaults(suiteName: "group.app.Spinify")
     
        if let current = shared?.object(forKey: "lastNumber") as? Int {
            shared?.set(current, forKey: "previousNumber")   // <-- yangi
        }
     
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

struct SpinifyEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let lastNumber: Int?
    let previousNumber: Int?
    let minValue: Int
    let maxValue: Int
    let bgColor: Color
}
struct Provider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> SpinifyEntry {
        SpinifyEntry(
            date: .now,
            configuration: ConfigurationAppIntent(),
            lastNumber: 42,
            previousNumber: nil,
            minValue: 1,
            maxValue: 100,
            bgColor: Color(red: 0.424, green: 0, blue: 1.0)
        )
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
        let lastNumber     = shared?.object(forKey: "lastNumber")     as? Int
        let previousNumber = shared?.object(forKey: "previousNumber") as? Int
        let minValue       = shared?.object(forKey: "minValue")       as? Int ?? 1
        let maxValue       = shared?.object(forKey: "maxValue")       as? Int ?? 1000

        let r = shared?.double(forKey: "bgR") ?? 0.424
        let g = shared?.double(forKey: "bgG") ?? 0.0
        let b = shared?.double(forKey: "bgB") ?? 1.0
        let bgColor = Color(red: r, green: g, blue: b)

        return SpinifyEntry(
            date: .now,
            configuration: configuration,
            lastNumber: lastNumber,
            previousNumber: previousNumber,
            minValue: minValue,
            maxValue: maxValue,
            bgColor: bgColor
        )
    }
}


private func localizedSpin() -> String {
    let code = UserDefaults(suiteName: "group.app.Spinify")?.string(forKey: "spinify_lang_code") ?? "en"
    return L10n.t("lets_spin", code: code)
}

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

            if let prev = entry.previousNumber {
                Text("\(localizedResultLabel()): \(prev)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.38))
                    .lineLimit(1)
            } else {
                Text("\(entry.minValue) – \(entry.maxValue)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.38))
            }

            Spacer()

            Button(intent: SpinIntent()) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .renderingMode(.template)
                    Text(localizedSpin())
                        .lineLimit(1)
                        .fixedSize()
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(entry.bgColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.white)
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.28), lineWidth: 1)
                )
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .containerBackground(entry.bgColor, for: .widget)
    }

    private func localizedResultLabel() -> String {
        let code = UserDefaults(suiteName: "group.app.Spinify")?
            .string(forKey: "spinify_lang_code") ?? "en"
        return L10n.t("last_result", code: code)
    }
}

struct HomeMediumWidgetView: View {
    var entry: SpinifyEntry

    var body: some View {
        HStack(alignment: .center, spacing: 0) {

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

                if let prev = entry.previousNumber {
                    Text("\(localizedResultLabel()): \(prev)")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.38))
                        .lineLimit(1)
                } else {
                    Text("\(entry.minValue) – \(entry.maxValue)")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.38))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(intent: SpinIntent()) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(.white.opacity(0.3), lineWidth: 1.5)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(entry.bgColor)
                        Text(localizedSpin())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(entry.bgColor)
                            .lineLimit(1)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .containerBackground(entry.bgColor, for: .widget)
    }

    private func localizedResultLabel() -> String {
        let code = UserDefaults(suiteName: "group.app.Spinify")?
            .string(forKey: "spinify_lang_code") ?? "en"
        return L10n.t("last_result", code: code)
    }
}

struct HomeLargeWidgetView: View {
    var entry: SpinifyEntry
 
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
 
            HStack {
                Text("SPINIFY")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(3.5)
                    .foregroundColor(.white.opacity(0.45))
                Spacer()
                Text("\(entry.minValue) – \(entry.maxValue)")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(.white.opacity(0.38))
            }
 
            Spacer()
 
            if let number = entry.lastNumber {
                Text("\(number)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.25)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("–")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.25))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
 
            Group {
                if let prev = entry.previousNumber {
                    Text("\(localizedResultLabel()): \(prev)")
                } else if entry.lastNumber == nil {
                    Text(localizedReadyLabel())
                } else {
                    Text(localizedReadyLabel())
                        .opacity(0)
                }
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white.opacity(0.5))
            .padding(.top, 4)
 
            Spacer()
 
            VStack(alignment: .leading, spacing: 8) {
                Text(localizedRangeLabel())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1.5)
 
                let progress: Double = {
                    guard let number = entry.lastNumber else { return 0 }
                    let range = Double(max(entry.maxValue - entry.minValue, 1))
                    return min(max(Double(number - entry.minValue) / range, 0), 1)
                }()
 
                Capsule()
                    .fill(.white.opacity(0.15))
                    .frame(height: 6)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.85))
                            .frame(height: 6)
                            .scaleEffect(x: max(progress, 0.02), anchor: .leading)
                    }
 
                HStack {
                    Text("\(entry.minValue)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                    Spacer()
                    Text("\(entry.maxValue)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
 
            Spacer()
 
            Button(intent: SpinIntent()) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(entry.bgColor)
                    Text(localizedSpin())
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(entry.bgColor)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .containerBackground(entry.bgColor, for: .widget)
    }
 
    private func localizedResultLabel() -> String {
        let code = UserDefaults(suiteName: "group.app.Spinify")?
            .string(forKey: "spinify_lang_code") ?? "en"
        return L10n.t("last_result", code: code)
    }
 
    private func localizedReadyLabel() -> String {
        let code = UserDefaults(suiteName: "group.app.Spinify")?
            .string(forKey: "spinify_lang_code") ?? "en"
        return L10n.t("tap_to_spin", code: code)
    }
 
    private func localizedRangeLabel() -> String {
        let code = UserDefaults(suiteName: "group.app.Spinify")?
            .string(forKey: "spinify_lang_code") ?? "en"
        return L10n.t("range", code: code).uppercased()
    }
}



struct LockScreenWidgetView: View {
    var entry: SpinifyEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularView(entry: entry)
        case .accessoryRectangular:
            RectangularView(entry: entry)
        case .accessoryInline:
            InlineView(entry: entry)
        default:
            CircularView(entry: entry)
        }
    }
}

private struct CircularView: View {
    var entry: SpinifyEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 1) {
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .font(.system(size: 10, weight: .semibold))
                    .opacity(0.7)

                if let number = entry.lastNumber {
                    Text("\(number)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                } else {
                    Text("–")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .opacity(0.4)
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

private struct RectangularView: View {
    var entry: SpinifyEntry

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "arrow.trianglehead.2.clockwise")
                .font(.system(size: 14, weight: .semibold))
                .opacity(0.7)

            VStack(alignment: .leading, spacing: 1) {
                if let number = entry.lastNumber {
                    Text("\(number)")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                } else {
                    Text("–")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .opacity(0.4)
                }

                Text("\(entry.minValue) – \(entry.maxValue)")
                    .font(.system(size: 11, weight: .medium))
                    .opacity(0.55)
            }

            Spacer()
        }
        .containerBackground(.clear, for: .widget)
    }
}

private struct InlineView: View {
    var entry: SpinifyEntry

    var body: some View {
        if let number = entry.lastNumber {
            Label("\(number)  ·  \(entry.minValue)–\(entry.maxValue)", systemImage: "arrow.trianglehead.2.clockwise")
        } else {
            Label("Spinify", systemImage: "arrow.trianglehead.2.clockwise")
        }
    }
}

struct SpinifyWidgetEntryView: View {
    var entry: SpinifyEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            HomeSmallWidgetView(entry: entry)
        case .systemMedium:
            HomeMediumWidgetView(entry: entry)
        case .systemLarge:
            HomeLargeWidgetView(entry: entry)
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            LockScreenWidgetView(entry: entry)
        default:
            HomeSmallWidgetView(entry: entry)
        }
    }
}

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
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.minValue = 1
        intent.maxValue = 100
        return intent
    }
}
