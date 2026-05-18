//
//  SpinView.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import SwiftUI
import Combine

struct SpinView: View {
    @ObservedObject var vm: SpinifyViewModel

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
    }

    // MARK: Portrait (original logic)
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            Spacer()
            rangeLabel
                .padding(.bottom, 48)
            numberDisplay
                .frame(height: 170)
            statusLabel
                .padding(.top, 20)
            Spacer()
            bottomButtons
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
        }
    }

    // MARK: Landscape
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            // Left: number display
            VStack {
                Spacer()
                rangeLabel
                    .padding(.bottom, 24)
                numberDisplay
                    .frame(height: 130)
                statusLabel
                    .padding(.top, 12)
                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Right: buttons
            VStack(spacing: 14) {
                Spacer()
                spinButtonView
                changeRangeButton
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
        }
    }

    // MARK: Subviews
    private var rangeLabel: some View {
        Text("\(Int(vm.state.minValue)) – \(Int(vm.state.maxValue))")
            .font(.system(size: 12, weight: .bold))
            .tracking(2)
            .foregroundColor(.white.opacity(0.4))
    }

    private var numberDisplay: some View {
        ZStack {
            if let number = vm.state.currentNumber {
                Text("\(number)")
                    .font(.system(size: isLandscape ? 80 : 110, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(vm.numberScale)
                    .opacity(vm.numberOpacity)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
                    .shadow(color: .white.opacity(0.15), radius: 40)
            } else {
                ReadyBadge()
            }
        }
    }

    private var statusLabel: some View {
        Text(
            vm.state.isSpinning ? vm.t("spinning") :
            vm.state.currentNumber != nil ? vm.t("tap_again") : vm.t("tap_begin")
        )
        .font(.system(size: 13, weight: .semibold))
        .tracking(1)
        .foregroundColor(.white.opacity(0.45))
        .animation(.easeInOut(duration: 0.3), value: vm.state.isSpinning)
    }

    private var spinButtonView: some View {
        Button(action: vm.spin) {
            HStack(spacing: 10) {
                if vm.state.isSpinning {
                    ProgressView()
                        .tint(.black)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .font(.system(size: 15, weight: .bold))
                }
                Text(vm.state.isSpinning ? vm.t("spinning") : vm.t("lets_spin"))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.white.opacity(vm.state.isSpinning ? 0.7 : 1))
            .clipShape(Capsule())
        }
        .disabled(vm.state.isSpinning)
    }

    private var changeRangeButton: some View {
        Button(action: vm.goBack) {
            Text(vm.t("change_range"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
        }
    }

    private var bottomButtons: some View {
        VStack(spacing: 14) {
            spinButtonView
            changeRangeButton
        }
    }
}
