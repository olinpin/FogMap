//
//  FogMapApp.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import SwiftUI

@main
struct FogMapApp: App {
    let dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
