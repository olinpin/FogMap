//
//  FogMapApp.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import SwiftUI
import CoreData

@main
struct FogMapApp: App {
//    let dataController: DataController
//    let locationManager: LocationManager
    
    init() {
//        self.dataController = DataController()
//        self.dataController = DataController.preview
//        self.locationManager = LocationManager(viewContext: dataController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            UIMapView()
                .ignoresSafeArea()
//            MapView()
//                .environment(\.managedObjectContext, dataController.container.viewContext)
//                .environmentObject(self.locationManager)
        }
    }
}
