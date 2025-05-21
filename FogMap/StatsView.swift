//
//  StatsView.swift
//  FogMap
//
//  Created by Oliver Hnát on 07.08.2024.
//


// TODO: Add % of countries explored, number of countries
// TODO: Add % of land explored
// TODO: Add graph of new explored land per day?

import SwiftUI

struct StatsView: View {
    @ObservedObject private var locationManager = LocationManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("Visited locations: \(locationManager.locations.count)")
                .font(.title3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StatsView()
}
