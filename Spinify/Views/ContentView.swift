//
//  ContentView.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var vm = SpinifyViewModel()

    var body: some View {
        ZStack {
            vm.bgColor
                .ignoresSafeArea()

            switch vm.state.screen {
            case .setup:
                SetupView(vm: vm)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            case .spin:
                SpinView(vm: vm)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: vm.state.screen)
        .onAppear {
            HapticManager.shared.prepare()
        }
    }
}

#Preview {
    ContentView()
}
