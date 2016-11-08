//
//  MapViewController.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/7/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
    var updatingLocation = true
    let latitudeDelta = 0.2
    let longitudeDelta = 0.2
    
    var annotations: [MapPin] = []
    
    let transitionManager = CLLocationManager()
    
    var overlay: MKOverlay?
    var route: MKRoute?
    
    var directionsView: UIView!
    var directionsTableView: UITableView!
    var showingDirections = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        
        mapView.delegate = self
        definesPresentationContext = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !WebServices.shared.userAuthTokenExists() || WebServices.shared.userAuthTokenExpired() {
            
            performSegue(withIdentifier: "PresentLoginNoAnimation", sender: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - IBActions
    @IBAction func logoutClicked(_ sender: Any) {
        UserStore.shared.logout {
            self.performSegue(withIdentifier:"PresentLogin", sender: self)
        }
    }
    
    
    
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        mapView.setRegion(region, animated: true)
        updatingLocation = false
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            
            let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            leftButton.setImage(#imageLiteral(resourceName: "info"), for: .normal)
            pinView!.leftCalloutAccessoryView = leftButton
            
            let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            rightButton.setImage(#imageLiteral(resourceName: "directions"), for: .normal)
            pinView!.rightCalloutAccessoryView = rightButton
            
            if let mapPin = annotation as? MapPin {
                let addressLabel = UILabel()
                addressLabel.numberOfLines = 0
                addressLabel.font = UIFont.systemFont(ofSize: 12)
                addressLabel.text = mapPin.subtitle
                addressLabel.sizeToFit()
                addressLabel.preferredMaxLayoutWidth = 240
                
                var labels = [addressLabel]
                
                if let phone = mapPin.phone {
                    let phoneLabel = UILabel()
                    phoneLabel.font = UIFont.systemFont(ofSize: 12)
                    phoneLabel.text = phone
                    labels.append(phoneLabel)
                }
                
                let stackView = UIStackView(arrangedSubviews: labels)
                stackView.axis = .vertical
                stackView.alignment = .leading
                stackView.distribution = .equalSpacing
                stackView.spacing = 4
                
                pinView!.detailCalloutAccessoryView = stackView
                
                pinView!.leftCalloutAccessoryView!.tag = 0
                pinView!.rightCalloutAccessoryView!.tag = 1
            }
            
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.overlay = overlay
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        renderer.lineWidth = 5.0
        renderer.lineCap = .round
        return renderer
    }
}


