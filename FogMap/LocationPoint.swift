//
//  LocationPoint.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import Foundation
import MapKit

class LocationPoint: Identifiable {
    let latitude: Double
    let longitude: Double
    let timestamp: Int
    let id: UUID
    
    init(latitude: Double, longitude: Double, timestamp: Int) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.id = UUID()
    }
    
    func findDistanceFrom(_ coordinate: LocationPoint) -> Double {
        let c1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let c2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return c1.distance(from: c2)
    }
}
