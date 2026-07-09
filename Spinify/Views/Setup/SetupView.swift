//
//  SetupView.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import SwiftUI
import Combine

struct SetupView: View {
    @ObservedObject var vm: SpinifyViewModel
    @State private var showLanguagePicker = false

    @Environment(\.verticalSizeClass) private var vSizeClass

    private var isLandscape: Bool { vSizeClass == .compact }

    var body: some View {
        Group {
            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet(vm: vm, isPresented: $showLanguagePicker)
        }
    }

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            topBar

            VStack(spacing: 28) {
                Spacer(minLength: 20)
                titleBlock
                    .padding(.top, 8)

                fromCard
                toCard

                Spacer(minLength: 10)
                spinButton
                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }

    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)

                Spacer()
                titleBlock
                Spacer()
                spinButton
                    .padding(.horizontal, 20)
                Spacer()
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 12) {
                fromCard
                toCard
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button(action: { showLanguagePicker = true }) {
                HStack(spacing: 5) {
                    Image(systemName: "globe")
                        .font(.system(size: 13, weight: .semibold))
                    Text(vm.t("language"))
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.white.opacity(0.15))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 12)
    }

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text(vm.t("app_title"))
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(vm.t("set_range"))
                .font(.system(size: 11, weight: .bold))
                .tracking(3)
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private var fromCard: some View {
        RangeCard(
            label: vm.t("from"),
            value: $vm.state.minValue,
            range: 1...max(2, vm.state.maxValue - 1)
        )
        .frame(maxHeight: .infinity)
        .onChange(of: vm.state.maxValue) { newValue in
            if vm.state.minValue >= newValue {
                vm.state.minValue = max(1, newValue - 1)
            }
        }
    }

    private var toCard: some View {
        RangeCard(
            label: vm.t("to"),
            value: $vm.state.maxValue,
            range: max(2, vm.state.minValue + 1)...1000
        )
        .frame(maxHeight: .infinity)
        .onChange(of: vm.state.minValue) { newValue in
            if vm.state.maxValue <= newValue {
                vm.state.maxValue = newValue + 1
            }
        }
    }

    private var spinButton: some View {
        Button(action: vm.proceed) {
            HStack(spacing: 8) {
                Text(vm.t("lets_spin"))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(vm.bgColor)
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(vm.bgColor)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .padding(.top, 4)
    }
}

struct EditableNumberText: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let fontSize: CGFloat

    @State private var isEditing = false
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            if isEditing {
                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .font(.system(size: fontSize, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .focused($isFocused)
                    .onSubmit { commit() }
            } else {
                numberText
                    .onTapGesture {
                        text = "\(value)"
                        isEditing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            isFocused = true
                        }
                    }
            }
        }
        .onChange(of: isFocused) { focused in
            if !focused && isEditing {
                commit()
            }
        }
    }

    @ViewBuilder
    private var numberText: some View {
        if #available(iOS 16.0, *) {
            Text("\(value)")
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25), value: value)
        } else {
            Text("\(value)")
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .animation(.spring(response: 0.25), value: value)
        }
    }

    private func commit() {
        let cleaned = text.filter { $0.isNumber }
        if let parsed = Int(cleaned) {
            let clamped = min(max(parsed, range.lowerBound), range.upperBound)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                value = clamped
            }
        }
        isEditing = false
        isFocused = false
    }
}
