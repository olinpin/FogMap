//
//  UIKitMapView.swift
//  FogMap
//
//  Created by Oliver Hnát on 04.08.2024.
//

import UIKit
import MapKit
import SwiftUI

class UIKitMapView: UIViewController {
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false // TODO: FIgure out if I want this
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationManager.shared.requestAuthorization()
        LocationManager.shared.requestLocation()
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        
        // add constraints
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

struct UIMapView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitMapView {
        return UIKitMapView()
    }
    
    func updateUIViewController(_ uiViewController: UIKitMapView, context: Context) {
        //
    }
    
    typealias UIViewControllerType = UIKitMapView
}
#Preview {
    var dataController = DataController()
    var locationManager = LocationManager(viewContext: dataController.container.viewContext)
    return UIKitMapView()
}
