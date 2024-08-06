//
//  DataController.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import Foundation
import CoreData
import CloudKit

class DataController: ObservableObject {
    
    let container = NSPersistentCloudKitContainer(name: "FogMap")
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    static var shared = DataController()
    
    static var preview: DataController {
        let result = DataController(inMemory: true)
        let viewContext = result.container.viewContext
        let home = PastLocations(context: viewContext)
        home.latitude = 50.187480
        home.longitude = 15.050138
        home.timestamp = 0
        let point2 = PastLocations(context: viewContext)
        point2.latitude = 50.186
        point2.longitude = 15.048138
        home.timestamp = 1
//        let point2 = PastLocations(context: viewContext)
//        point2.latitude = 50.0
//        point2.longitude = 15.050138
//        home.timestamp = 1
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
        
        let storeDescription = container.persistentStoreDescriptions.first
        
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.oliverhnat.FogMap")
        
        storeDescription?.cloudKitContainerOptions = cloudKitOptions
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
