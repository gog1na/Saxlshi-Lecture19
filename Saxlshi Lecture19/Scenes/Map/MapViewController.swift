//
//  MapViewController.swift
//  Saxlshi Lecture19
//
//  Created by Giorgi Goginashvili on 1/19/23.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    let locationDistance:Double = 500
    var destinationCoordinate = CLLocationCoordinate2D()
    var sourceCoordinate = CLLocationCoordinate2D()
    var overlay: MKOverlay?
    var steps: [MKRoute.Step] = []
    var stepCounter = 0
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupMapView()
        getUserLocation()
        hideKeyboardWhenTappedAround()
        fromTextField.delegate = self
        toTextField.delegate = self
    }
    
    //MARK: - Actions
    @IBAction func didTapDrawRoute(_ sender: UIButton) {
        drawRoute()
    }
    
    @IBAction func didTapClear(_ sender: UIButton) {
        self.steps.removeAll()
        directionsView.isHidden = true
        if let overlay = overlay {
            mapView.removeOverlay(overlay)
        }
    }
    
    //MARK: - Methods
    private func configureUI() {
        bottomView.layer.opacity = 0.7
        directionsView.layer.cornerRadius = 20
        fromTextField.attributedPlaceholder = NSAttributedString(string: "From", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        toTextField.attributedPlaceholder = NSAttributedString(string: "To", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        
        directionsView.isHidden = true
    }
    
    private func setupMapView() {
        mapView.delegate = self
    }
    
    private func getUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func handleAuthorizationStatus(locationManager: CLLocationManager, status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        case .authorizedAlways:
            print("authorizedAlways")
            break
        case .authorizedWhenInUse:
            if let center = locationManager.location?.coordinate {
                centerViewToUserLocation(center: center)
            }
            break
        case .authorized:
            print("authorized")
            break
        default:
            break
        }
    }
    
    private func centerViewToUserLocation(center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
    }
    
    private func drawRoute() {
        guard let fromText = fromTextField.text else {return}
        guard let toText = toTextField.text else {return}
        
        let fromTextGeoCoder = CLGeocoder()
        fromTextGeoCoder.geocodeAddressString(fromText) { placemarks, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            guard let placemarks = placemarks,
                  let placemark = placemarks.first,
                  let location = placemark.location else {return}
            let sourceCoordinate = location.coordinate
            self.sourceCoordinate = sourceCoordinate
        }
        let toTextGeoCoder = CLGeocoder()
        toTextGeoCoder.geocodeAddressString(toText) { placemarks, err in
            if let err = err {
                print(err.localizedDescription)
            }
            guard let placemarks = placemarks,
                  let placemark = placemarks.first,
                  let location = placemark.location else {return}
            let destinationCoordinate = location.coordinate
            self.destinationCoordinate = destinationCoordinate
            self.mapRoute(sourceCoordinate: self.sourceCoordinate, destinationCoordinate: destinationCoordinate)
        }
    }
    
    private func mapRoute(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let routeRequest = MKDirections.Request()
        routeRequest.source  = sourceItem
        routeRequest.destination = destinationItem
        routeRequest.transportType = .automobile
        
        let directions = MKDirections(request: routeRequest)
        directions.calculate { response, err in
            if let err = err {
                print(err.localizedDescription)
            }
            guard let response = response,
                  let route = response.routes.first else {return}
            
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
            self.getRouteSteps(route: route)
        }
    }
    
    private func getRouteSteps(route: MKRoute) {
        let steps = route.steps
        self.steps = steps
        
        stepCounter += 1
        let initialMessage = "In \(steps[stepCounter].distance) meters \(steps[stepCounter].instructions), then in  \(steps[stepCounter + 1].distance) meters, \(steps[stepCounter].instructions)"
        directionsView.isHidden = false
        directionsView.layer.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.5).cgColor
        directionsLabel.textColor = .black
        directionsLabel.text = initialMessage
    }
    
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        self.overlay = overlay
        renderer.strokeColor = .black
        return renderer
    }
}

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationStatus(locationManager: manager, status: status)
        
    }
}

//MARK: - UITextFieldDelegate
extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder  = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            drawRoute()
        }
        return true
    }
}

