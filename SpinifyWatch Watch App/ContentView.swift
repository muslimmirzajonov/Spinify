//
//  ContentView.swift
//  SpinifyWatch Watch App
//
//  Created by Muslim Mirzajonov on 18/05/26.
//

import SwiftUI

struct WatchContentView: View {
    @StateObject private var vm = SpinifyViewModel()

    var body: some View {
        ZStack {
            vm.bgColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: vm.bgColor)

            if vm.state.screen == .setup {
                WatchSetupView(vm: vm)
            } else {
                WatchSpinView(vm: vm)
            }
        }
    }
}

struct WatchSetupView: View {
    @ObservedObject var vm: SpinifyViewModel
    @State private var step: Int = 0
    @AppStorage("hasUsedCrown") private var hasUsedCrown = false
    
    var body: some View {
        ZStack {
            Color(red: 0.424, green: 0, blue: 1.0).ignoresSafeArea()

            if step == 0 {
                stepView(
                    stepNum: "1 / 2",
                    label: vm.t("from"),
                    value: $vm.state.minValue,
                    range: 1...max(2, vm.state.maxValue - 1),
                    isLast: false
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                stepView(
                    stepNum: "2 / 2",
                    label: vm.t("to"),
                    value: $vm.state.maxValue,
                    range: max(2, vm.state.minValue + 1)...1000,
                    isLast: true
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
    }

    @ViewBuilder
    private func stepView(
        stepNum: String,
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        isLast: Bool
    ) -> some View {
        VStack(spacing: 0) {
            Text(stepNum)
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 6)

            Text(label)
                .font(.system(size: 12, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 2)

            Spacer()

            Text("\(Int(value.wrappedValue))")
                .font(.system(size: 58, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .focusable(true)
                .digitalCrownRotation(
                    value,
                    from: range.lowerBound,
                    through: range.upperBound,
                    by: 1,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
                .onChange(of: value.wrappedValue) {
                    hasUsedCrown = true
                }

            if !hasUsedCrown {
                HStack(spacing: 3) {
                    Image(systemName: "digitalcrown.arrow.clockwise")
                        .font(.system(size: 9))
                    Text("crown")
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 4)
                .transition(.opacity)
            }

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .fill(step == 0 ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 5, height: 5)
                Circle()
                    .fill(step == 1 ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 5, height: 5)
            }
            .padding(.bottom, 8)

            Button(action: {
                if isLast {
                    vm.proceed()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        step = 1
                    }
                }
            }) {
                Text(isLast ? vm.t("lets_spin") : "Next →")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isLast ? Color(red: 0.424, green: 0, blue: 1.0) : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 8)
    }
}


struct WatchSpinView: View {
    @ObservedObject var vm: SpinifyViewModel
    
    private var isSmallWatch: Bool {
        WKInterfaceDevice.current().screenBounds.height < 185
    }

    var body: some View {
        VStack(spacing: isSmallWatch ? 4 : 8) {
            Text("\(Int(vm.state.minValue))–\(Int(vm.state.maxValue))")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundColor(.white.opacity(0.4))

            Spacer(minLength: 0)

            ZStack {
                if let number = vm.state.currentNumber {
                    Text("\(number)")
                        .font(.system(size: isSmallWatch ? 46 : 54,
                                      weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(vm.numberScale)
                        .opacity(vm.numberOpacity)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                } else {
                    Text("READY")
                        .font(.system(size: isSmallWatch ? 15 : 18,
                                      weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(height: isSmallWatch ? 55 : 70)

            Spacer(minLength: 0)

            // Spin button
            Button(action: vm.spin) {
                ZStack {
                    Text(vm.t("lets_spin"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .opacity(0)
                    
                    HStack(spacing: 5) {
                        if vm.state.isSpinning {
                            ProgressView()
                                .tint(.black)
                                .scaleEffect(0.7)
                                .frame(width: 14, height: 14)
                        }
                        Text(vm.state.isSpinning ? vm.t("spinning") : vm.t("lets_spin"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .foregroundColor(vm.bgColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isSmallWatch ? 7 : 10)
                .background(Color.white.opacity(vm.state.isSpinning ? 0.7 : 1))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(vm.state.isSpinning)


            Button(action: vm.goBack) {
                Text(vm.t("change_range"))
                    .font(.system(size: isSmallWatch ? 10 : 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .buttonStyle(.plain)
            .padding(.bottom, isSmallWatch ? 2 : 4)
            
            Spacer(minLength: 4)
        }
        .padding(.horizontal, 8)
        .padding(.top, isSmallWatch ? 2 : 4)
    }
}
