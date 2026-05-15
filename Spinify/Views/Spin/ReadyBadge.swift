//
//  ReadyBadge.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 14/05/26.
//

import SwiftUI
import Combine

struct ReadyBadge: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 6) {
            Text("READY")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .tracking(6)
                .foregroundColor(.white.opacity(0.9))
            Rectangle()
                .fill(.white.opacity(0.4))
                .frame(width: pulse ? 60 : 30, height: 2)
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
        }
        .onAppear { pulse = true }
    }
}
