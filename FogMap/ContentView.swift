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
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        Map(position: $position) {
            ForEach(locations) { location in
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                Marker("Test", coordinate: coordinate)
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            HStack {
                Spacer()
                Button(action: {
                    getLocations()
                    print(locations)
                }) {
                    Text("Get latest locations")
                }
                Spacer()
            }
            .padding(.top)
            .background(.thinMaterial)
        })
        
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
