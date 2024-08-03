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
    
    var pointRadius: Double = 3
    
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
            HStack {
                Spacer()
                Text("Current number of points: \(locationManager.locations.count)")
                Spacer()
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
