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
        VStack(spacing: 8) {
            Text("READY")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .tracking(8)
                .foregroundColor(.white.opacity(0.9))
            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(width: pulse ? 70 : 24, height: 2.5)
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
        }
        .onAppear { pulse = true }
    }
}
