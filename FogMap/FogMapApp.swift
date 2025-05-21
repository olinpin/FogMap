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
    let dataController: DataController
    let locationManager: LocationManager

    init() {
        self.dataController = DataController()
        self.locationManager = LocationManager(viewContext: dataController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(locationManager)
        }
    }
}
