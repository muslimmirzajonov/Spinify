//
//  RangeCard.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import SwiftUI
import Combine

struct RangeCard: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    private var safeRange: ClosedRange<Double> {
        let lo = range.lowerBound
        let hi = range.upperBound
        guard lo < hi else { return lo...(lo + 1) }
        return lo...hi
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Text("\(Int(value))")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: value)

            Slider(value: $value, in: safeRange, step: 1)
                .tint(.white)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.07))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}
