//
//  LocationManager.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import CoreLocation
import UIKit
import CoreData
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var locations: [PastLocations]

    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.locations = []
        do {
            let request = NSFetchRequest<PastLocations>(entityName: "PastLocations")
            self.locations = try viewContext.fetch(request)
        } catch {
            print("Something went wrong fetching locations")
        }
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }

    
    func requestLocation() {
        manager.requestAlwaysAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Authorization not determined")
        case .restricted:
            print("Authorization restricted")
        case .denied:
            print("Authorization denied")
        case .authorizedAlways:
            print("Authorization always authorized")
        case .authorizedWhenInUse:
            print("Authorization when in use authorized")
        @unknown default:
            print("Authorization went wrong")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
        let loc = PastLocations(context: self.viewContext)
        loc.latitude = location.coordinate.latitude
        loc.longitude = location.coordinate.longitude
        do {
            try viewContext.save()
            self.locations.append(loc)
            print("Added new location")
        } catch {
            print("SOMETHING WENT WRONG")
        }
    }
}
