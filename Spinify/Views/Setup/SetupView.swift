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

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("Spinify")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("SET YOUR RANGE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, 8)

            RangeCard(
                label: "FROM",
                value: $vm.state.minValue,
                range: 1...max(2, vm.state.maxValue - 1)
            )
            .onChange(of: vm.state.maxValue) {
                if vm.state.minValue >= vm.state.maxValue {
                    vm.state.minValue = max(1, vm.state.maxValue - 1)
                }
            }

            RangeCard(
                label: "TO",
                value: $vm.state.maxValue,
                range: max(2, vm.state.minValue + 1)...100
            )
            .onChange(of: vm.state.minValue) {
                if vm.state.maxValue <= vm.state.minValue {
                    vm.state.maxValue = vm.state.minValue + 1
                }
            }

            Button(action: vm.proceed) {
                HStack(spacing: 8) {
                    Text("Let's Spin")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 28)
    }
}
