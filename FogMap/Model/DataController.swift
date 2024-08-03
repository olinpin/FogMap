//
//  DataController.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "FogMap")
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    static var preview: DataController {
        let result = DataController(inMemory: true)
        let viewContext = result.container.viewContext
//        let locations: [PastLocations] = []
        let home = PastLocations(context: viewContext)
        home.latitude = 50.187480
        home.longitude = 15.050138
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
