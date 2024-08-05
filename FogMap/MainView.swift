//
//  MainView.swift
//  FogMap
//
//  Created by Oliver Hnát on 05.08.2024.
//

import SwiftUI

struct MainView: View {
    
    @State var pointRadius: Double = 100
    var body: some View {
        UIMapView()
            .ignoresSafeArea()
//            .safeAreaInset(edge: .bottom, content: {
//                VStack {
////                    Text("HER")
//                }
//                .padding([.top, .horizontal])
//            })
//            .background(.thinMaterial)
    }
}

#Preview {
    MainView()
}
