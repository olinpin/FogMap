//
//  UIKitMapView.swift
//  FogMap
//
//  Created by Oliver Hnát on 04.08.2024.
//

import UIKit
import MapKit
import SwiftUI

class UIKitMapView: UIViewController, MKMapViewDelegate {
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let coordinates = [
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        CLLocationCoordinate2D(latitude: 37.3352, longitude: -122.0322),
        CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
    ]
    
    private var maskView: UIView?
    private var circles: [MKCircle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        LocationManager.shared.requestAuthorization()
        LocationManager.shared.requestLocation()

        setupUI()
        addCircles()
        createMaskView()
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        mapView.delegate = self
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // TODO: This should be user's current location
//        let initialLocation = coordinates[0]
        let initialLocation = LocationManager.shared.locations.map({CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}).first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.showsUserTrackingButton = true
    }
    
    private func addCircles() {
        var coords = circles.map({$0.coordinate})
        for coordinate in LocationManager.shared.locations.map({CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}) {
            if coords.contains(where: {coordinate.latitude == $0.latitude && coordinate.longitude == $0.longitude}) {
                continue
            }
            let circle = MKCircle(center: coordinate, radius: 1000)
            self.circles.append(circle)
            mapView.addOverlay(circle)
        }
    }
    
    private func createMaskView() {
        maskView?.removeFromSuperview()
        
        let newMaskView = UIView(frame: mapView.bounds)
        newMaskView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        newMaskView.isUserInteractionEnabled = false
        
        mapView.addSubview(newMaskView)
        maskView = newMaskView
        
        updateMask()
    }
    
    private func updateMask() {
        
        guard let maskView = maskView else { return }
        addCircles()
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        
        let path = UIBezierPath(rect: mapView.bounds)
        var combinedPath = CGMutablePath()
        
        for circle in circles {
            let circlePoint = mapView.convert(circle.coordinate, toPointTo: mapView)
            let radiusInPoints = radiusInPointsForCircle(circle)
            if circlePoint.y < -radiusInPoints/2 || circlePoint.x < -radiusInPoints / 2 {
                continue
            }
            let circlePath = UIBezierPath(arcCenter: circlePoint, radius: radiusInPoints, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            combinedPath = combinedPath.union(circlePath.cgPath) as! CGMutablePath
        }
        path.append(UIBezierPath(cgPath: combinedPath))
        
        maskLayer.path = path.cgPath
        maskView.layer.mask = maskLayer
    }
    
    private func radiusInPointsForCircle(_ circle: MKCircle) -> CGFloat {
        let centerCoordinate = circle.coordinate
        let radiusCoordinate = CLLocationCoordinate2D(
            latitude: centerCoordinate.latitude,
            longitude: centerCoordinate.longitude + (circle.radius / 111320.0)
        )
        
        let centerPoint = mapView.convert(centerCoordinate, toPointTo: mapView)
        let radiusPoint = mapView.convert(radiusCoordinate, toPointTo: mapView)
        
        let dx = radiusPoint.x - centerPoint.x
        let dy = radiusPoint.y - centerPoint.y
        return sqrt(dx*dx + dy*dy)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.fillColor = UIColor.clear
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView?.frame = mapView.bounds
        updateMask()
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        maskView?.isHidden = true
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateMask()
        maskView?.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMask()
        maskView?.isHidden = false
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
//    let dataController = DataController.preview
//    let locationManager = LocationManager(viewContext: dataController.container.viewContext)
    return UIKitMapView()
}
