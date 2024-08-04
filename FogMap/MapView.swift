//
//  MapView.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import SwiftUI
import CoreData
import MapKit


struct MapView: View {
    
    @State var pointRadius: Double = 200
    @State var pointMaxSize: Double = 1000
    
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.managedObjectContext) var moc
    
    
    var body: some View {
        ZStack {
            customMapView(locationManager: locationManager, pointRadius: $pointRadius, pointMaxSize: $pointMaxSize)
        }
    }
    
    func getPolygon() -> MKPolygon {
        let sortedLocations = self.locationManager.locations.sorted(by: {$0.timestamp > $1.timestamp})
        var filledRect: [CLLocationCoordinate2D] = []
        
        for location in sortedLocations {
            let cord = location.getCLLocationCoordinate2D()
            filledRect.append(cord)
        }
        return MKPolygon(coordinates: filledRect, count: filledRect.count)
    }
    
}

struct customMapView: View {
    
    
    //    @State var position: MapCameraPosition = .region(.init(center: .init(latitude: 50.187480, longitude: 15.050138), latitudinalMeters: 500, longitudinalMeters: 500))
    @State var position: MapCameraPosition = .automatic
    var locationManager: LocationManager
    
    @Binding var pointRadius: Double
    @Binding var pointMaxSize: Double
    
    func getSuplementedLocations() -> [LocationPoint] {
        let sortedLocations = self.locationManager.locations.sorted(by: {$0.timestamp > $1.timestamp})
        var filledRect: [CLLocationCoordinate2D] = []
        
        for location in sortedLocations {
            let cord = location.getCLLocationCoordinate2D()
            filledRect.append(cord)
        }
        
        var suplementedLocations: [LocationPoint] = []
        if !sortedLocations.isEmpty {
            suplementedLocations.append(sortedLocations.last!)
        }
        if sortedLocations.isEmpty {
            return []
        }
        for i in 1..<sortedLocations.count {
            let diffLat = sortedLocations[i].latitude - sortedLocations[i-1].latitude
            let diffLon = sortedLocations[i].longitude - sortedLocations[i-1].longitude
            var pointsInBetween = Int(sortedLocations[i].findDistanceFrom(sortedLocations[i-1]))
            pointsInBetween /= (Int(pointRadius) != 0 ? Int(pointRadius) : 1)
            pointsInBetween += 1
            for j in 1..<pointsInBetween {
                let loc1 = LocationPoint(
                    latitude: sortedLocations[i-1].latitude + Double(j) * diffLat / Double(pointsInBetween),
                    longitude: sortedLocations[i-1].longitude + Double(j) * diffLon / Double(pointsInBetween),
                    timestamp: 0
                )
                suplementedLocations.append(loc1)
            }
            suplementedLocations.append(sortedLocations[i])
        }
        return suplementedLocations
    }
    
    var body: some View {
        Map(position: $position) {
            ForEach(self.getSuplementedLocations()) { location in
                let coordinate = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                MapCircle(center: coordinate, radius: pointRadius)
                    .foregroundStyle(.red.opacity(0.75))
            }
            
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack {
                HStack {
                    Spacer()
                    Text("Current number of points: \(self.getSuplementedLocations().count)")
                    Spacer()
                }
                HStack {
                    Button(action: {
                        pointMaxSize *= 10
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    Button(action: {
                                                if pointMaxSize / 10 > 100 {
                                                    pointMaxSize /= 10
                                                } else {
                        pointMaxSize = 100
                                                }
                    }) {
                        Image(systemName: "minus.circle.fill")
                    }
                }
                .font(.title)
                .padding(.top, 10)
                Slider(value: self.$pointRadius, in: 100...pointMaxSize){
                    Text("Something")
                } minimumValueLabel: {
                    Text("100")
                } maximumValueLabel: {
                    Text("\(Int(pointMaxSize))")
                }
                Text("Point size: \(String(format: "%.2f", pointRadius))m")
            }
            .padding([.top, .horizontal])
            .background(.thinMaterial)
        })
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
        .onAppear {
            self.locationManager.requestAuthorization()
        }
    }
}

#Preview {
    @State var locations: [PastLocations] = []
    
    return MapView()
        .environment(\.managedObjectContext, DataController.preview.container.viewContext)
        .environmentObject(LocationManager(viewContext: DataController.preview.container.viewContext))
}
