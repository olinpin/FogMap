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
        requestFromCoreData()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }
    
    func requestFromCoreData() {
        do {
            let request = NSFetchRequest<PastLocations>(entityName: "PastLocations")
            let res = try viewContext.fetch(request)
            self.locations = res.map {
                LocationPoint(latitude: $0.latitude,
                              longitude: $0.longitude,
                              timestamp: Int($0.timestamp))
            }
        } catch {
            print("Something went wrong fetching locations")
        }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard let location = newLocations.last else { return }
        self.userLocation = location
        let date = Int64(Date().timeIntervalSince1970)
        let point = LocationPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: Int(date))
        for madePoint in self.locations {
            if point.findDistanceFrom(madePoint) < 50 {
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
            print(error)
            print("SOMETHING WENT WRONG")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}
