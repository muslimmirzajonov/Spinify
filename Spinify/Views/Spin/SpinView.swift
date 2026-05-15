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

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("\(Int(vm.state.minValue)) – \(Int(vm.state.maxValue))")
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 48)

            ZStack {
                if let number = vm.state.currentNumber {
                    Text("\(number)")
                        .font(.system(size: 110, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(vm.numberScale)
                        .opacity(vm.numberOpacity)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
                        .shadow(color: .white.opacity(0.15), radius: 40)
                } else {
                    ReadyBadge()
                }
            }
            .frame(height: 170)

            Text(
                vm.state.isSpinning ? vm.t("spinning") :
                vm.state.currentNumber != nil ? vm.t("tap_again") : vm.t("tap_begin")
            )
            .font(.system(size: 13, weight: .semibold))
            .tracking(1)
            .foregroundColor(.white.opacity(0.45))
            .padding(.top, 20)
            .animation(.easeInOut(duration: 0.3), value: vm.state.isSpinning)

            Spacer()

            VStack(spacing: 14) {
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

                Button(action: vm.goBack) {
                    Text(vm.t("change_range"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }
}
