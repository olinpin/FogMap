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
    
    static var shared = LocationManager(viewContext: DataController.shared.viewContext)

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
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }

    
    func requestAuthorization() {
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
        let date = Int64(Date().timeIntervalSince1970)
        let point = LocationPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: Int(date))
        for madePoint in self.locations {
            if point.findDistanceFrom(madePoint) < 100 {
                return
            }
        }
        let loc = PastLocations(context: self.viewContext)
        loc.latitude = point.latitude
        loc.longitude = point.longitude
        loc.timestamp = date
        do {
            try viewContext.save()
            self.locations.append(point)
            print("Added new location")
        } catch {
            print("SOMETHING WENT WRONG")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}
