//
//  FogMapApp.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import SwiftUI
import CoreData
import UIKit

@main
struct FogMapApp: App {
    // Bridge UIKit's AppDelegate to ensure location monitoring is started even
    // when the application is relaunched in the background.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

//    let dataController: DataController
//    let locationManager: LocationManager
    
    init() {
//        self.dataController = DataController()
//        self.dataController = DataController.preview
//        self.locationManager = LocationManager(viewContext: dataController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
//            MapView()
//                .environment(\.managedObjectContext, dataController.container.viewContext)
//                .environmentObject(self.locationManager)
        }
    }
}
