//
//  ContentView.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import SwiftUI
import Combine

struct SpinifyRootView: View {
    @StateObject private var vm = SpinifyViewModel()

    var body: some View {
        ZStack {
            vm.bgColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: vm.bgColor)

            if vm.state.screen == .setup {
                SetupView(vm: vm)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                SpinView(vm: vm)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
    }
}
