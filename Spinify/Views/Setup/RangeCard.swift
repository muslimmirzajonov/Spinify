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

    @State private var isEditing = false
    @State private var text = ""
    @FocusState private var isFocused: Bool

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

                numberField(fontSize: isCompact ? 32 : 52)

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

    @ViewBuilder
    private func numberField(fontSize: CGFloat) -> some View {
        if isEditing {
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .fixedSize()
                .focused($isFocused)
                .onSubmit { commit() }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { commit() }
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .onChange(of: isFocused) { focused in
                    if !focused { commit() }
                }
        } else {
            numberText(fontSize: fontSize)
                .onTapGesture {
                    text = "\(Int(value))"
                    isEditing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        isFocused = true
                    }
                }
        }
    }

    @ViewBuilder
    private func numberText(fontSize: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            Text("\(Int(value))")
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25), value: value)
        } else {
            Text("\(Int(value))")
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .animation(.spring(response: 0.25), value: value)
        }
    }

    private func commit() {
        let cleaned = text.filter { $0.isNumber }
        if let parsed = Double(cleaned) {
            value = min(max(parsed, safeRange.lowerBound), safeRange.upperBound)
        }
        isEditing = false
        isFocused = false
    }
}
