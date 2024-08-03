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
    @State var position: MapCameraPosition = .automatic
    @State var centerCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @State var pointRadius: Double = 3
    @State var pointMaxSize: Double = 100
    
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.managedObjectContext) var moc
    
    
    
    var body: some View {
        Map(position: $position) {
            ForEach(locationManager.locations) { location in
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                MapCircle(center: coordinate, radius: pointRadius)
                    .foregroundStyle(.red.opacity(0.75))
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack {
                HStack {
                    Spacer()
                    Text("Current number of points: \(locationManager.locations.count)")
                    Spacer()
                }
                HStack {
                    Button(action: {
                        pointMaxSize *= 10
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    Button(action: {
                        pointMaxSize /= 10
                    }) {
                        Image(systemName: "minus.circle.fill")
                    }
                }
                .font(.title)
                .padding(.top, 10)
                Slider(value: self.$pointRadius, in: 0...pointMaxSize){
                    Text("Something")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("\(Int(pointMaxSize))")
                }
                Text("Point size: \(String(format: "%.2f", pointRadius))m")
            }
            .padding([.top, .horizontal])
            .background(.thinMaterial)

            
        })
        .mapStyle(.standard(elevation: .realistic))
        .onMapCameraChange { mapCameraUpdateContext in
            self.centerCoord = mapCameraUpdateContext.camera.centerCoordinate
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
    }
}

#Preview {
    @State var locations: [PastLocations] = []
    
    return MapView()
        .environment(\.managedObjectContext, DataController.preview.container.viewContext)
        .environmentObject(LocationManager(viewContext: DataController.preview.container.viewContext))
}
