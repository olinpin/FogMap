//
//  ContentView.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//

import SwiftUI
import CoreData
import MapKit


struct ContentView: View {
    @State var locations: [PastLocations] = []
    
    @State var position: MapCameraPosition = .automatic
    
    private var pointRadius: Double = 30
    
    @State var centerCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        Map(position: $position) {
            ForEach(locations) { location in
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                MapCircle(center: coordinate, radius: pointRadius)
                    .foregroundStyle(.red.opacity(0.75))
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            HStack {
                Spacer()
                Button(action: {
                    getLocations()
                    print(locations)
                }) {
                    Text("Get")
                }
                Spacer()
                Button(action: {
                    saveCenterCameraLocation()
                    print(locations)
                }) {
                    Text("Save")
                }
                Spacer()
            }
            .padding([.top, .horizontal])
            .background(.thinMaterial)
        })
        .mapStyle(.standard(elevation: .realistic))
        .onMapCameraChange { mapCameraUpdateContext in
            self.centerCoord = mapCameraUpdateContext.camera.centerCoordinate
        }
        
        
    }
    
    func saveCenterCameraLocation() {
        let location = PastLocations(context: moc)
        location.latitude = self.centerCoord.latitude
        location.longitude = self.centerCoord.longitude
        do {
            try moc.save()
        } catch {
            print("Something went wrong while saving the location")
        }
        getLocations()
    }
    
    func getLocations() {
        let request = NSFetchRequest<PastLocations>(entityName: "PastLocations")
        do {
            locations = try moc.fetch(request)
        } catch {
            print("Something went wrong while fetching locations")
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
}
