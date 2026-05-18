//
//  SpinifyWidgetBundle.swift
//  SpinifyWidget
//
//  Created by Muslim Mirzajonov on 18/05/26.
//

import WidgetKit
import SwiftUI

@main
struct SpinifyWidgetBundle: WidgetBundle {
    var body: some Widget {
        SpinifyWidget()
        SpinifyWidgetControl()
    }
}
