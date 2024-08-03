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
    @Published var locations: [LocationPoint]

    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.locations = []
        super.init()
        do {
            let request = NSFetchRequest<PastLocations>(entityName: "PastLocations")
            let res = try viewContext.fetch(request)
            for location in res {
                let point = LocationPoint(latitude: location.latitude, longitude: location.longitude, timestamp: Int(location.timestamp))
                self.locations.append(point)
            }
        } catch {
            print("Something went wrong fetching locations")
        }
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
        let date = Int64(Date().timeIntervalSince1970)
        loc.timestamp = date
        do {
            try viewContext.save()
            let point = LocationPoint(latitude: loc.latitude, longitude: loc.longitude, timestamp: Int(loc.timestamp))
            self.locations.append(point)
            print("Added new location")
        } catch {
            print("SOMETHING WENT WRONG")
        }
    }
}
