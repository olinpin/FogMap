//
//  MainView.swift
//  FogMap
//
//  Created by Oliver Hnát on 05.08.2024.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        UIMapView()
            .ignoresSafeArea()
//            .safeAreaInset(edge: .bottom, content: {
//                VStack {
//                    Text("\(LocationManager.shared.locations.map({$0.getCLLocationCoordinate2D()}))")
//                }
//                .padding([.top, .horizontal])
//            })
//            .background(.thinMaterial)
    }
}

#Preview {
    MainView()
}
