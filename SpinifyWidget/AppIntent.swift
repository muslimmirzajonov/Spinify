//
//  AppIntent.swift
//  SpinifyWidget
//
//  Created by Muslim Mirzajonov on 18/05/26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Spinify" }
    static var description: IntentDescription { "Raqam diapazonini tanlang" }

    @Parameter(title: "Minimum", default: 1)
    var minValue: Int

    @Parameter(title: "Maximum", default: 1000)
    var maxValue: Int
}
