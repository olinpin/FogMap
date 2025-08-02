//
//  ScreenTimeView.swift
//  FogMap
//

import SwiftUI

struct ScreenTimeView: View {
    @StateObject private var manager = ScreenTimeManager()

    var body: some View {
        VStack(spacing: 20) {
            if manager.authorizationStatus == .authorized {
                Text("Today's Screen Time")
                    .font(.title2)
                Text(manager.formattedScreenTime())
                    .font(.largeTitle)
            } else {
                Text("Screen Time access is required.")
                    .multilineTextAlignment(.center)
                Button("Grant Permission") {
                    manager.requestAuthorization()
                }
            }
        }
        .padding()
        .task {
            if manager.authorizationStatus == .authorized {
                await manager.fetchScreenTime()
            }
        }
    }
}

#Preview {
    ScreenTimeView()
}

