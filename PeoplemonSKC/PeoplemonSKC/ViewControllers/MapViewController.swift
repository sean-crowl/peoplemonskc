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
    let latitudeDelta = 0.020
    let longitudeDelta = 0.020
    
    var annotations: [MapPin] = []
    var overlay: MKOverlay?
    var firstLocation = true
    
    var timer: Timer?
    
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
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        
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
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        stopTimer()
    }
    
    func loadMap() {
        if let coordinate = locationManager.location?.coordinate {
            let checkIn = Person(coordinate: coordinate)
            WebServices.shared.postObject(checkIn, completion: { (object, error) in
                
            })
        }
        
        let nearby = Person(radiusInMeters: Double(Constants.radiusInMeters))
        WebServices.shared.getObjects(nearby) { (objects, error) in
            if let objects = objects {
                let oldAnnotations = self.annotations
                self.annotations = []
                for person in objects {
                    let pin = MapPin(person: person)
                    self.annotations.append(pin)
                }
                self.mapView.addAnnotations(self.annotations)
                self.mapView.removeAnnotations(oldAnnotations)
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(loadMap), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = false
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let mapPin = view.annotation as? MapPin, let person = mapPin.person, let name = person.userName, let userId = person.userID {
            let alert = UIAlertController(title: "Catch User", message: "Catch \(name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Catch", style: .default, handler: { (action) in
                let catchPerson = Person(userID: userId, radiusInMeters: Double(Constants.radiusInMeters))
                WebServices.shared.postObject(catchPerson, completion: { (object, error) in
                    if let error = error {
                        self.present(Utils.createAlert(message: error), animated: true, completion: nil)
                    } else {
                        self.present(Utils.createAlert(message: "User Caught"), animated: true, completion: nil)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.overlay = overlay
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        renderer.lineCap = CGLineCap.round
        return renderer
    }
}
