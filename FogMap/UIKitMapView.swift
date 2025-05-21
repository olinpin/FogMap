//
//  UIKitMapView.swift
//  FogMap
//
//  Created by Oliver Hnát on 04.08.2024.
//

import UIKit
import MapKit
import SwiftUI
import Combine

class UIKitMapView: UIViewController, MKMapViewDelegate {
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    private var locationsCancellable: AnyCancellable?
    private var userLocationCancellable: AnyCancellable?

    
    private var initialLocationSet = false
    private var maskView: UIView?
    private var circles: [MKCircle] = []

    private func observeLocationChanges() {
        locationsCancellable = LocationManager.shared.$locations
            .sink { [weak self] _ in
                self?.addCircles()
                self?.updateMask()
            }
    }

    private func observeUserLocation() {
        userLocationCancellable = LocationManager.shared.$userLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self = self else { return }
                if !self.initialLocationSet {
                    let region = MKCoordinateRegion(
                        center: location.coordinate,
                        latitudinalMeters: 10000,
                        longitudinalMeters: 10000)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.setUserTrackingMode(.follow, animated: true)
                    self.initialLocationSet = true
                }
            }
    }
    deinit {
        locationsCancellable?.cancel()
        userLocationCancellable?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        LocationManager.shared.requestAuthorization()
        LocationManager.shared.requestLocation()

        addCircles()
        createMaskView()
        observeLocationChanges()
        observeUserLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !initialLocationSet {
            setInitialLocation()
        }
    }
    
    func setInitialLocation() {
        var initialLocation = LocationManager.shared.locations.map({$0.getCLLocationCoordinate2D()}).last ?? nil
        if initialLocation == nil {
            initialLocation = LocationManager.shared.userLocation?.coordinate
        }
        let defaultLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let region = MKCoordinateRegion(center: initialLocation ?? defaultLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        if initialLocation == nil {
            mapView.setUserTrackingMode(.follow, animated:true)
        }
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
        mapView.showsUserLocation = true
        mapView.showsUserTrackingButton = true
    }
    
    private func addCircles() {
        let coords = circles.map({$0.coordinate})
        for coordinate in LocationManager.shared.locations.map({$0.getCLLocationCoordinate2D()}) {
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
        newMaskView.backgroundColor = UIColor.white
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
        
        for circle in circles {
            let circlePoint = mapView.convert(circle.coordinate, toPointTo: mapView)
            let radiusInPoints = radiusInPointsForCircle(circle)
            if circlePoint.y < -radiusInPoints/2 || circlePoint.x < -radiusInPoints / 2 {
                continue
            }
            let circlePath = UIBezierPath(arcCenter: circlePoint, radius: radiusInPoints, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            path.append(circlePath)
        }

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
        updateMaskContinuously()
    }
    
    private func updateMaskContinuously() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateMask()
        CATransaction.commit()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateMaskContinuously()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMaskContinuously()
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
