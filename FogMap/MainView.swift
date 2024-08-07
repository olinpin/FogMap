//
//  MainView.swift
//  FogMap
//
//  Created by Oliver Hnát on 05.08.2024.
//

import SwiftUI

struct MainView: View {
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray5
    }
    
    @State var selectedTab = "Map"

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Group {
                    UIMapView()
                        .ignoresSafeArea(edges: .top)
                        .tag("Map")
                        .tabItem {
                            Image(systemName: "star")
                            Text("Anki")
                        }
                    StatsView()
                        .tag("Stats")
                        .tabItem {
                            Text("Statistics")
                            Image(systemName: "chart.bar")
                        }
                    SettingsView()
                        .tag("Settings")
                        .tabItem {
                            Image(systemName: "gear")
                                .padding()
                            Text("Settings")
                        }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
//            .safeAreaInset(edge: .bottom, content: {
//                VStack {
//                    Text("\(LocationManager.shared.locations.count)")
//                }
//                .padding([.top, .horizontal])
//            })
//            .background(.thinMaterial)
    }
}

#Preview {
    MainView()
}
