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
        let lo = range.lowerBound, hi = range.upperBound
        guard lo < hi else { return lo...(lo + 1) }
        return lo...hi
    }

    var body: some View {
        GeometryReader { geo in
            let isCompact = geo.size.height < 80
            VStack(alignment: .leading, spacing: isCompact ? 4 : 10) {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.5))

                Text("\(Int(value))")
                    .font(.system(size: isCompact ? 32 : 52, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.25), value: value)

                Slider(value: $value, in: safeRange, step: 1)
                    .tint(.white)
            }
            .padding(isCompact ? 12 : 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(.white.opacity(0.12))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
        }
    }
}
